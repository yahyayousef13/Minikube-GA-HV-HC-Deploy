# Vault on Kubernetes Using Helm

This repository contains a Helm chart for deploying HashiCorp Vault with TLS encryption on Kubernetes. It automates the process of deploying Vault with secure communication using custom TLS certificates. The project also includes deployment scripts and Kubernetes resources for easy deployment and management.

## Project Structure

```
├── .github
│   └── workflows                    # GitHub Actions CI/CD workflows
├── docker
│   └── Dockerfile                   # Dockerfile(s) for building Vault container (if any)
├── helm/                             # Helm chart directory
│   ├── Chart.yaml                    # Helm chart metadata and configuration
│   ├── values.yaml                   # Values file where you define configuration settings
│   ├── templates/                    # Templates for Kubernetes manifests
│   │   ├── deployment.yaml           # Deployment configuration for Vault
│   │   ├── configmap.yaml            # ConfigMap for Vault's configuration file (vault.hcl)
│   │   ├── secret.yaml               # Secret to store TLS certificates (vault-ssl-cert)
│   │   ├── service.yaml              # Service configuration (vault-service)
│   │   ├── ingress.yaml              # Ingress configuration for Vault access
│   ├── certs/                        # Folder for storing your TLS certificates (tls.crt, tls.key)
│   │   ├── tls.crt                   # TLS certificate for Vault
│   │   ├── tls.key                   # TLS private key for Vault
├── kubernetes/                       # Kubernetes resources (optional, can be used for other resources)
│   ├── namespace.yaml                # Optional: Namespace resource for organizing resources
├── scripts/                          # Deployment scripts (optional, for automating Helm install/upgrade)
│   ├── deploy-vault.sh               # Script to deploy/update Vault using Helm
├── README.md                         # Project documentation
├── .gitattributes                    # Git attributes file (for Git settings)
├── .gitignore                        # Git ignore file to avoid unnecessary files in the repository
```

## Prerequisites

Before you start, make sure you have the following installed:

- **Kubernetes Cluster**: A running Kubernetes cluster (can be on local or cloud platforms like GKE, EKS, AKS, etc.)
- **Helm**: [Helm](https://helm.sh/) installed and configured to manage Kubernetes applications.
- **kubectl**: The Kubernetes command-line tool for interacting with your cluster.

### TLS Certificates

This setup uses **TLS** for secure communication with Vault. You'll need to have your TLS certificate (`tls.crt`) and private key (`tls.key`). Place them in the `helm/certs/` directory.

If you don’t have a certificate, you can generate self-signed certificates for testing purposes.

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/vault-k8s-helm.git
cd vault-k8s-helm
```

### Step 2: Configure the Helm Values

You can adjust the settings of your Vault deployment by modifying the `helm/values.yaml` file. This file contains configuration options for the deployment, including the port and the service type.

For example, change the `service.type` to `LoadBalancer` for a cloud-based environment:

```yaml
service:
  port: 8200
  type: LoadBalancer
```

### Step 3: Deploy Vault using Helm

Run the following command to deploy or upgrade Vault using the Helm chart:

```bash
helm upgrade --install vault ./helm
```

This command will:
- Install or upgrade the Vault deployment on your Kubernetes cluster.
- Create necessary Kubernetes resources such as deployments, services, secrets, and ingress.
  
### Step 4: Access Vault

If you're using an **Ingress**, you can access Vault via the specified hostname (`vault.local` in this case). Ensure your DNS or `/etc/hosts` file is updated to resolve the `vault.local` domain to the IP of your ingress controller.

For example:

```
127.0.0.1 vault.local
```

### Step 5: Verify the Deployment

To verify if Vault has been deployed correctly:

1. Check the status of the Vault pods:

   ```bash
   kubectl get pods -n vault-deployment
   ```

2. Check the service and ingress:

   ```bash
   kubectl get svc -n vault-deployment
   kubectl get ingress -n vault-deployment
   ```

### Step 6: Using Vault

Once Vault is up and running, you can interact with it via the Vault UI or API:

- **Vault UI**: Open a browser and navigate to `https://vault.local:8200`.
- **Vault CLI**: Use `vault` CLI to interact with the Vault server.

Example for initializing Vault:

```bash
vault operator init
```

## Customizing the Deployment

To modify the deployment settings, you can adjust the Helm `values.yaml` file or use `--set` flags during the Helm install/upgrade. 

For example, to change the number of replicas, run:

```bash
helm upgrade --install vault ./helm --set replicaCount=2
```

### Step 7: Updating Vault Deployment

To update Vault or make changes to the Helm chart, simply modify the `helm/` directory (e.g., update the `values.yaml`, `deployment.yaml`, etc.), then re-run the following command:

```bash
helm upgrade --install vault ./helm
```

## Deployment Scripts

The `scripts/` directory contains a script to automate the deployment:

- **`deploy-vault.sh`**: This script can be used to deploy or update Vault using Helm:

```bash
./scripts/deploy-vault.sh
```

Make sure the script has the right permissions (`chmod +x deploy-vault.sh`) to execute.

## Cleanup

To delete the Vault deployment, run:

```bash
helm uninstall vault -n vault-deployment
```

This will delete all resources associated with the Vault deployment, including deployments, services, secrets, and ingress.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```

Let me know if you'd like any further edits!