# Use the official n8n base image
FROM n8nio/n8n:latest

# The base image already contains n8n and its dependencies.
# The necessary user, workdir, and entrypoint are also pre-configured.
# We only need to ensure the correct port is exposed for Fly.io.

# The fly.toml is configured to use port 8080 internally.
EXPOSE 8080

# The CMD is inherited from the base image, which is typically ["n8n"]
