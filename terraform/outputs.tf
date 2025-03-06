output "minikube_status" {
  value = fileexists("minikube_status.txt") ? file("minikube_status.txt") : "Minikube status unknown"
}

output "helm_app_status" {
  description = "Helm deployment status"
  value       = helm_release.my_app.status
}

output "github_runner_status" {
  description = "GitHub Runner Status"
  value       = null_resource.github_runner.id != "" ? "GitHub Runner is configured and running!" : "GitHub Runner setup failed."
}

output "monitoring_status" {
  description = "Monitoring Stack Deployment"
  value       = helm_release.monitoring.status
}
