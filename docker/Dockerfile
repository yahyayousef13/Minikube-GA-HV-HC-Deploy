# Use the official HashiCorp Vault image
FROM hashicorp/vault:latest

# Set working directory
WORKDIR /vault

# Copy Vault configuration file (Ensure you have config.hcl in your repo)
COPY docker/config.hcl /vault/config/config.hcl

# Expose Vault's default API port
EXPOSE 8200

# Health check to ensure Vault is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s \
  CMD curl -f http://127.0.0.1:8200/v1/sys/health || exit 1

# Start Vault with a config file
CMD ["vault", "server", "-config=/vault/config/config.hcl"]
