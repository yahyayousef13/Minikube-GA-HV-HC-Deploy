# 1️⃣ Deploy Minikube inside Docker Desktop
resource "docker_container" "minikube" {
  name  = "minikube"
  image = "gcr.io/k8s-minikube/kicbase:v0.0.35"
  restart = "always"
  privileged = true

  mounts {
    target = "/var/lib/docker"
    type   = "bind"
    source = "/mnt/wsl/docker-desktop/docker-desktop-proxy"
  }
}

# 2️⃣ Deploy Helm Release (Application)
resource "helm_release" "my_app" {
  name       = "my-app"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"

  values = [file("${path.module}/helm/values.yaml")]

  depends_on = [docker_container.minikube]
}

# 3️⃣ Deploy GitHub Runner for Minikube
resource "null_resource" "github_runner" {
  provisioner "local-exec" {
    command = <<EOT
      curl -o actions-runner-linux.tar.gz -L "https://github.com/actions/runner/releases/download/v2.308.0/actions-runner-linux-x64-2.308.0.tar.gz"
      mkdir -p /home/ubuntu/actions-runner && cd /home/ubuntu/actions-runner
      tar xzf ~/actions-runner-linux.tar.gz
      ./config.sh --url https://github.com/${var.github_owner}/${var.github_repo} --token ${var.github_token}
      ./run.sh
    EOT
  }

  depends_on = [helm_release.my_app]
}

# 4️⃣ Deploy Monitoring Stack (Prometheus & Grafana)
resource "helm_release" "monitoring" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [file("${path.module}/helm/monitoring-values.yaml")]

  depends_on = [helm_release.my_app]
}

# 5️⃣ Trigger GitHub Actions CI/CD Pipeline
resource "null_resource" "trigger_github_action" {
  provisioner "local-exec" {
    command = <<EOT
      curl -X POST -H "Accept: application/vnd.github+json" \
      -H "Authorization: token ${var.github_token}" \
      https://api.github.com/repos/${var.github_owner}/${var.github_repo}/actions/workflows/${var.github_workflow}/dispatches \
      -d '{"ref":"main"}'
    EOT
  }
  depends_on = [null_resource.github_runner]
}
