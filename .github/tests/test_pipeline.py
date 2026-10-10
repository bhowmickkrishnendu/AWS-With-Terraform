"""Exercise the deployment DAG, including GitHub's implicit success() guard."""
from pathlib import Path
import json
import os
import re
import shutil
import subprocess
import unittest

import yaml

ROOT = Path(__file__).resolve().parents[2]


def load(name):
    return yaml.load((ROOT / '.github/workflows' / name).read_text(), Loader=yaml.BaseLoader)


class DeploymentGraph:
    def __init__(self, jobs, cancelled=False):
        self.jobs = jobs
        self.results = {}
        self.outputs = {}
        self.cancelled = cancelled

    def dependencies(self, job):
        needs = self.jobs[job].get('needs', [])
        return [needs] if isinstance(needs, str) else needs

    def ancestors(self, job):
        result = set(self.dependencies(job))
        for dependency in self.dependencies(job):
            result.update(self.ancestors(dependency))
        return result

    def eligible(self, job):
        expression = self.jobs[job].get('if', 'success()').strip()
        expression = expression.removeprefix('${{').removesuffix('}}').strip()
        if not re.search(r'\b(success|failure|always|cancelled)\(', expression):
            expression = 'success() && (' + expression + ')'
        success = all(self.results.get(name) == 'success' for name in self.ancestors(job))
        expression = expression.replace('success()', str(success)).replace('always()', 'True').replace('cancelled()', str(self.cancelled))
        expression = re.sub(r'needs\.([\w-]+)\.outputs\.has_changes', lambda m: repr(self.outputs.get(m[1], '')), expression)
        expression = re.sub(r'needs\.([\w-]+)\.result', lambda m: repr(self.results.get(m[1], '')), expression)
        expression = expression.replace('&&', ' and ').replace('||', ' or ').replace('!', ' not ')
        return bool(eval(expression, {'__builtins__': {}}, {}))

    def execute(self, changes, failures=()):
        for stack in ('networking', 'storage', 'compute'):
            plan, apply = stack + '_plan', stack + '_apply'
            self.results[plan] = ('failure' if plan in failures else 'success') if self.eligible(plan) else 'skipped'
            if self.results[plan] == 'success':
                self.outputs[plan] = 'true' if stack in changes else 'false'
            self.results[apply] = ('failure' if apply in failures else 'success') if self.eligible(apply) else 'skipped'
        return self.results


class PipelineTests(unittest.TestCase):
    def setUp(self):
        self.jobs = load('terraform-apply.yml')['jobs']

    def test_compute_only_change_survives_upstream_skips(self):
        results = DeploymentGraph(self.jobs).execute({'compute'})
        self.assertEqual(results['networking_apply'], 'skipped')
        self.assertEqual(results['storage_apply'], 'skipped')
        self.assertEqual(results['compute_plan'], 'success')
        self.assertEqual(results['compute_apply'], 'success')

    def test_old_condition_reproduces_incident(self):
        self.jobs['compute_apply']['if'] = "needs.compute_plan.outputs.has_changes == 'true'"
        self.assertEqual(DeploymentGraph(self.jobs).execute({'compute'})['compute_apply'], 'skipped')

    def test_every_change_combination(self):
        stacks = ('networking', 'storage', 'compute')
        for mask in range(8):
            changed = {stack for index, stack in enumerate(stacks) if mask & (1 << index)}
            with self.subTest(changed=changed):
                results = DeploymentGraph(self.jobs).execute(changed)
                for stack in stacks:
                    self.assertEqual(results[stack + '_plan'], 'success')
                    self.assertEqual(results[stack + '_apply'], 'success' if stack in changed else 'skipped')

    def test_failed_plan_or_apply_blocks_later_stacks(self):
        for failed in ('networking_plan', 'networking_apply', 'storage_plan', 'storage_apply', 'compute_plan'):
            with self.subTest(failed=failed):
                results = DeploymentGraph(self.jobs).execute({'networking', 'storage', 'compute'}, {failed})
                self.assertEqual(results['compute_apply'], 'skipped')
                if failed.startswith('networking'):
                    self.assertEqual(results['storage_plan'], 'skipped')

    def test_cancelled_workflow_cannot_apply(self):
        results = DeploymentGraph(self.jobs, cancelled=True).execute({'networking', 'storage', 'compute'})
        for stack in ('networking', 'storage', 'compute'):
            self.assertEqual(results[stack + '_apply'], 'skipped')

    def test_skipped_changed_upstream_blocks_next_plan(self):
        for stack, next_stack in (('networking', 'storage'), ('storage', 'compute')):
            graph = DeploymentGraph(self.jobs)
            graph.results[stack + '_plan'] = 'success'
            graph.results[stack + '_apply'] = 'skipped'
            graph.outputs[stack + '_plan'] = 'true'
            self.assertFalse(graph.eligible(next_stack + '_plan'))
            graph.outputs[stack + '_plan'] = ''
            self.assertFalse(graph.eligible(next_stack + '_plan'))
            graph.outputs[stack + '_plan'] = 'false'
            self.assertTrue(graph.eligible(next_stack + '_plan'))

    def test_live_workflows_share_concurrency_and_branch_guards(self):
        for name in ('terraform-apply.yml', 'terraform-plan.yml', 'terraform-drift.yml', 'terraform-destroy.yml'):
            workflow = load(name)
            self.assertEqual(workflow['concurrency']['group'], 'terraform-live-${{ github.repository }}')
            self.assertEqual(workflow['concurrency']['cancel-in-progress'], 'false')
        for name, job in (('terraform-plan.yml', 'plan'), ('terraform-drift.yml', 'drift'), ('terraform-destroy.yml', 'destroy')):
            self.assertEqual(load(name)['jobs'][job]['if'], "github.ref == 'refs/heads/master'")

    def test_dependency_gate_and_action_pins(self):
        self.assertEqual(set(self.jobs['deploy-result']['needs']), {stack + '_' + phase for stack in ('networking', 'storage', 'compute') for phase in ('plan', 'apply')})
        self.assertEqual(self.jobs['deploy-result']['if'], 'always()')
        for path in (ROOT / '.github/workflows').glob('*.yml'):
            for job in load(path.name)['jobs'].values():
                if 'uses' in job:
                    self.assertRegex(job['uses'], r'@[a-f0-9]{40}$')
                for item in job.get('steps', []):
                    if 'uses' in item:
                        self.assertRegex(item['uses'], r'@[a-f0-9]{40}$')
                    if 'run' in item:
                        self.assertNotIn('-lock=false', item['run'])

    def test_result_gate_rejects_incomplete_deployment(self):
        jq = os.environ.get('TEST_JQ') or shutil.which('jq')
        self.assertIsNotNone(jq, 'jq is required to test the actual deployment gate')
        script = self.jobs['deploy-result']['steps'][0]['run']
        query = script.split("jq -e '", 1)[1].rsplit("'", 1)[0]

        def gate(results, outputs):
            payload = {name: {'result': result, 'outputs': {'has_changes': outputs[name]} if name in outputs else {}} for name, result in results.items()}
            return subprocess.run([jq, '-e', query], input=json.dumps(payload), text=True, capture_output=True).returncode

        for changed in (set(), {'compute'}, {'networking', 'storage', 'compute'}):
            graph = DeploymentGraph(self.jobs)
            graph.execute(changed)
            self.assertEqual(gate(graph.results, graph.outputs), 0)
        graph = DeploymentGraph(self.jobs)
        graph.execute({'compute'})
        graph.results['compute_apply'] = 'skipped'
        self.assertNotEqual(gate(graph.results, graph.outputs), 0)
        graph.results['compute_apply'] = 'success'
        graph.outputs.pop('compute_plan')
        self.assertNotEqual(gate(graph.results, graph.outputs), 0)
        graph = DeploymentGraph(self.jobs)
        graph.execute({'networking'}, {'networking_apply'})
        self.assertNotEqual(gate(graph.results, graph.outputs), 0)


if __name__ == '__main__':
    unittest.main()
