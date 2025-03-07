
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

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "kubernetes" {
  config_path = "/mnt/c/Users/ashis/.kube/config"
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
