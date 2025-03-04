terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.15"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "docker" {}

provider "kubernetes" {
  config_path = "~/.kube/config"  # Adjust this path if needed
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
