#!/bin/bash

echo "Checking Minikube status..."
MINIKUBE_STATUS=$(minikube status --format="{{.Host}}")

if [[ "$MINIKUBE_STATUS" != "Running" ]]; then
  echo "Starting Minikube..."
  if minikube start --driver=docker; then
    echo "Minikube started successfully."

    # Ensure the .kube directory exists
    mkdir -p ~/.kube

    # Copy kubeconfig file and fix Windows paths for WSL
    cp /mnt/c/Users/ashis/.kube/config ~/.kube/config
    sed -i 's|C:\\Users\\ashis|/mnt/c/Users/ashis|g' ~/.kube/config
    sed -i 's|\\|/|g' ~/.kube/config

    # Ensure Minikube certificates are correctly linked
    mkdir -p ~/.minikube
    cp -r /mnt/c/Users/ashis/.minikube/* ~/.minikube/

    echo "Verifying Kubernetes Pods:"
    kubectl get pods --all-namespaces
  else
    echo "Failed to start Minikube."
    exit 1
  fi
else
  echo "Minikube is already running. Skipping start..."
fi
