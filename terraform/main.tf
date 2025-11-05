resource "null_resource" "deploy_stellartrack" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "powershell -ExecutionPolicy Bypass -NoProfile -File ${path.module}/deploy.ps1"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "powershell -ExecutionPolicy Bypass -NoProfile -File ${path.module}/rollback.ps1"
  }
}
