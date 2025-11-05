resource "null_resource" "deploy_stellartrack" {
  triggers = {
    always_run = timestamp()  # Force run on every apply
  }

  # Deploy
  provisioner "local-exec" {
    command = "powershell -ExecutionPolicy Bypass -File \"${path.module}\\deploy.ps1\""
  }

  # Rollback on destroy
  provisioner "local-exec" {
    when    = destroy
    command = "powershell -ExecutionPolicy Bypass -File \"${path.module}\\rollback.ps1\""
  }
}
