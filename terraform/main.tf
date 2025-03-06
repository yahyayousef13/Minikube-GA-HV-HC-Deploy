# 1️⃣ Deploy Minikube inside Docker Desktop (Only if not running)
resource "null_resource" "init_minikube" {
  provisioner "local-exec" {
    command = <<EOT
      if ! minikube status | grep -E "Running|Stopped"; then
        echo "Starting Minikube..."
        minikube start --driver=docker
        echo "Minikube started successfully."
        mkdir -p ~/.kube
        cp /mnt/c/Users/ashis/.kube/config ~/.kube/config
        sed -i "s|C:\\\\Users\\\\ashis|/mnt/c/Users/ashis|g" ~/.kube/config
        sed -i "s|\\\\|/|g" ~/.kube/config
        echo "Verifying Kubernetes Pods:"
        kubectl get pods --all-namespaces
      else
        echo "Minikube is already running. Skipping start..."
      fi
    EOT
  }
}


# 2️⃣ Deploy Helm Release (Application)
resource "null_resource" "install_helm" {
  provisioner "local-exec" {
    command = <<EOT
      wsl bash -c '
      if ! command -v helm &> /dev/null; then
        echo "Helm is not installed. Installing Helm..."
        curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        echo "Helm installed successfully."
      else
        echo "Helm is already installed. Skipping installation."
      fi'
    EOT
  }

  depends_on = [null_resource.init_minikube]
}

resource "helm_release" "my_app" {
  name       = "my-app"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"

  values = [file("${path.module}/../helm/values.yaml")]

  depends_on = [null_resource.install_helm]
}


# 3️⃣ Deploy GitHub Runner for Minikube
resource "null_resource" "github_runner" {
  provisioner "local-exec" {
    command = <<EOT
      wsl bash -c '
      RUNNER_DIR="$HOME/actions-runner"

      if [ ! -d "$RUNNER_DIR" ]; then
        echo "Setting up GitHub Runner..."
        mkdir -p "$RUNNER_DIR" && cd "$RUNNER_DIR"
        
        curl -o actions-runner-linux.tar.gz -L "https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz"
        tar xzf actions-runner-linux.tar.gz
        
        ./config.sh --url https://github.com/${var.github_owner}/${var.github_repo} --token ${var.github_token}
      fi

      cd "$RUNNER_DIR"

      echo "Starting GitHub Runner in the background..."
      nohup ./run.sh &> runner.log &'
    EOT
  }

  depends_on = [helm_release.my_app]
}


# 4️⃣ Deploy Monitoring Stack (Prometheus & Grafana)
resource "helm_release" "monitoring" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [file("${path.module}/../helm/values.yaml")]

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
