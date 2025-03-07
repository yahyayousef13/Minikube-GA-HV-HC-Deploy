output "minikube_status" {
  value = fileexists("minikube_status.txt") ? file("minikube_status.txt") : "Minikube status unknown"
}



output "github_runner_status" {
  description = "GitHub Runner Status"
  value       = null_resource.github_runner.id != "" ? "GitHub Runner is configured and running!" : "GitHub Runner setup failed."
}
