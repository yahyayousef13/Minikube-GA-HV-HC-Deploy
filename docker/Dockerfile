# Use the official HashiCorp Vault image with a specified version
FROM hashicorp/vault:1.13.3

# Set working directory
WORKDIR /vault

# Create necessary directories
RUN mkdir -p /vault/config /vault/data

# Copy Vault configuration file
COPY docker/config.hcl /vault/config/config.hcl

# Expose Vault API port
EXPOSE 8200

# Health check with vault CLI (ensure Vault is initialized & unsealed)
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s \
  CMD vault status || exit 1

# Start Vault with the configuration file
CMD ["vault", "server", "-config=/vault/config/config.hcl"]
