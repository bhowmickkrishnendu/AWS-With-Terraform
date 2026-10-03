# Custom bootstrap for the private app instance.
# NOTE: no shebang here — it is added automatically by locals.tf.

yum update -y
yum install -y nginx
systemctl enable --now nginx
