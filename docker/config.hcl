# Storage backend using local file system
storage "file" {
  path = "/vault/data"
}

# Listener configuration
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"  # Only for local testing, not recommended in production
}

# Enable the Vault UI
ui = true

# Disable memory lock to allow running as a non-root user
disable_mlock = true

# Seal configuration (Shamir Secret Sharing)
seal "shamir" {
  secret_shares    = 3
  secret_threshold = 2
}
