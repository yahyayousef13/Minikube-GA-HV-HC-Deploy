# 1️⃣ Deploy Minikube inside Docker Desktop (Only if not running)
provider "null" {}

# Start Minikube
# Start Minikube (Using Windows Minikube from WSL)
resource "null_resource" "init_minikube" {
  provisioner "local-exec" {
    command = <<EOT
      wsl bash -c "  
        MINIKUBE_STATUS=$(minikube status --format=\"{.Host}\")
        if [[ \"$MINIKUBE_STATUS\" != \"Running\" ]]; then
          echo \"Starting Minikube...\"
          if minikube start --driver=docker; then
            echo \"Minikube started successfully.\"
            mkdir -p ~/.kube
            [ -f \"/mnt/c/Users/ashis/.kube/config\" ] && cp /mnt/c/Users/ashis/.kube/config ~/.kube/config
            mkdir -p ~/.minikube
            cp -r /mnt/c/Users/ashis/.minikube/* ~/.minikube/
            kubectl get pods --all-namespaces
          else
            echo \"Failed to start Minikube.\"
            exit 1
          fi
        else
          echo \"Minikube is already running. Skipping start...\"
        fi"
    EOT
  }

}
provider "null" {}

resource "null_resource" "start_minikube" {
  provisioner "local-exec" {
    command = <<EOT
      export KUBECONFIG=$HOME/.kube/config
      minikube start --driver=docker
      kubectl cluster-info
              MINIKUBE_STATUS=$(minikube status --format=\"{.Host}\")
        if [[ \"$MINIKUBE_STATUS\" != \"Running\" ]]; then
          echo \"Starting Minikube...\"
          if minikube start --driver=docker; then
            echo \"Minikube started successfully.\"
            mkdir -p ~/.kube
            [ -f \"/mnt/c/Users/ashis/.kube/config\" ] && cp /mnt/c/Users/ashis/.kube/config ~/.kube/config
            mkdir -p ~/.minikube
            cp -r /mnt/c/Users/ashis/.minikube/* ~/.minikube/
            kubectl get pods --all-namespaces
          else
            echo \"Failed to start Minikube.\"
            exit 1
          fi
        else
          echo \"Minikube is already running. Skipping start...\"
        fi
    EOT
  }
}

# 2️⃣ Deploy Helm Release (Application)
resource "null_resource" "install_helm" {
  provisioner "local-exec" {
    command = <<EOT
      if ! command -v helm &> /dev/null; then
        echo "Installing Helm..."
        curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        echo "Helm installed successfully."
      else
        echo "Helm is already installed."
      fi
    EOT
  }
  depends_on = [null_resource.init_minikube]
}

# 3️⃣ Deploy GitHub Runner for Minikube
resource "null_resource" "github_runner" {
  provisioner "local-exec" {
    command = <<EOT
      wsl bash -c '
        RUNNER_DIR="$HOME/actions-runner"
        if [ -d "$RUNNER_DIR" ] && [ -f "$RUNNER_DIR/.runner" ]; then
          echo "GitHub Runner is already configured. Starting it now..."
        else
          echo "Setting up GitHub Runner..."
          mkdir -p "$RUNNER_DIR" && cd "$RUNNER_DIR"
          curl -o actions-runner-linux.tar.gz -L "https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz"
          tar xzf actions-runner-linux.tar.gz
          chmod +x config.sh run.sh
          ./config.sh --url https://github.com/Ashishm96/Minikube-GA-HV-HC-Deploy --token "YOUR_GITHUB_TOKEN"
        fi
        cd "$RUNNER_DIR"
        nohup ./run.sh &> runner.log &
      '
    EOT
  }
}


# 4️⃣ Deploy Monitoring Stack (Prometheus & Grafana)
# Placeholder for monitoring stack deployment using Helm

# 5️⃣ Trigger GitHub Actions CI/CD Pipeline
resource "null_resource" "trigger_github_action" {
  provisioner "local-exec" {
    command = <<EOT
      set -e
      response=$(curl -o /dev/null -s -w "%%{http_code}" -X POST -H "Accept: application/vnd.github+json" \
        -H "Authorization: token ${var.github_token}" \
        https://api.github.com/repos/${var.github_owner}/${var.github_repo}/actions/workflows/${var.github_workflow}/dispatches \
        -d '{"ref":"main"}')

      if [ "$response" -eq 204 ]; then
        echo "✅ GitHub Action triggered successfully."
      else
        echo "❌ Failed to trigger GitHub Action. HTTP Response: $response"
      fi
    EOT
  }
  depends_on = [null_resource.github_runner]
}
