# Storage backend using local file system
storage "file" {
  path = "/vault/data"
}

# Listener configuration
#listener "tcp" {
#  address     = "0.0.0.0:8200"
#  tls_disable = "false"  # Only for local testing, not recommended in production
#}
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/vault/certs/tls.crt"
  tls_key_file  = "/vault/certs/tls.key"
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
