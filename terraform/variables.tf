variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub username or organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_workflow" {
  description = "GitHub Actions workflow filename"
  type        = string
  default     = "deploy-vault.yaml"
}
