# Use the official HashiCorp Vault image with a specified version
FROM hashicorp/vault:1.13.3

# Set working directory
WORKDIR /vault

# Create necessary directories
RUN mkdir -p /vault/config /vault/data /vault/certs \
    && chmod -R 750 /vault \
    && chown -R vault:vault /vault

# Copy Vault configuration file
COPY docker/config.hcl /vault/config/config.hcl

# Ensure Vault is running with necessary permissions
USER vault

# Expose Vault API port
EXPOSE 8200

# Health check to ensure Vault is initialized & unsealed
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s \
  CMD vault status || exit 1

# Start Vault with the configuration file
ENTRYPOINT ["vault"]
CMD ["server", "-config=/vault/config/config.hcl"]