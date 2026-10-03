"""Exercise saved-plan destruction using a temporary local Terraform stack."""

from pathlib import Path
import subprocess
import tempfile


def terraform(root: Path, *arguments: str, expected: int = 0) -> str:
    result = subprocess.run(
        ["terraform", f"-chdir={root}", *arguments],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != expected:
        raise AssertionError(
            f"terraform {arguments[0]} returned {result.returncode}, expected {expected}\n"
            f"{result.stdout}\n{result.stderr}"
        )
    return result.stdout


with tempfile.TemporaryDirectory(prefix="terraform-destroy-test-") as temp:
    root = Path(temp)
    (root / "main.tf").write_text(
        'terraform { required_version = ">= 1.14.0, < 1.15.0" }\n'
        'resource "terraform_data" "disposable" { input = "local-only" }\n',
        encoding="utf-8",
    )

    terraform(root, "init", "-backend=false", "-input=false")
    terraform(root, "apply", "-auto-approve", "-input=false")
    assert "terraform_data.disposable" in terraform(root, "state", "list")

    terraform(
        root,
        "plan",
        "-destroy",
        "-detailed-exitcode",
        "-input=false",
        "-out=destroy.tfplan",
        expected=2,
    )
    terraform(root, "apply", "-input=false", "destroy.tfplan")
    assert terraform(root, "state", "list").strip() == ""

print("Disposable local stack was destroyed with its saved plan.")
