#!/bin/bash

# Script to fix the n8n workflow by updating Fly.io secrets and restarting the app
# Run this on your local machine where Fly CLI is installed

echo "Setting FLY_API_TOKEN secret..."
fly secrets set FLY_API_TOKEN="FlyV1 fm2_lJPECAAAAAAACmz1xBAVGgM4+a8JtfERA7uVYxniwrVodHRwczovL2FwaS5mbHkuaW8vdjGUAJLOABP2FR8Lk7lodHRwczovL2FwaS5mbHkuaW8vYWFhL3YxxDxhTY4V8eD9zVKxDKAu2/fkHeYHxDIsc42y4Y1veKVhB7Nj6SWjFzq5jeFOMAHb8Dz4XLNtwRENYwLtdQTETvecKwOcbG3abX+HT8IuYr+xzzSm3rIGJsFv0/HOlvuFF0emNZDkKmlKIYREPuvRLEWV0Ygi28g84oqq2ci2yui9nNSgZwL/1eqsivO/fsQg4BCBa3eFR3CUlJEboGsVKMYFupZzUM72EyYmakyxpx8=,fm2_lJPETvecKwOcbG3abX+HT8IuYr+xzzSm3rIGJsFv0/HOlvuFF0emNZDkKmlKIYREPuvRLEWV0Ygi28g84oqq2ci2yui9nNSgZwL/1eqsivO/fsQQTKyOJClhDC5aXOyPtIOrS8O5aHR0cHM6Ly9hcGkuZmx5LmlvL2FhYS92MZgEks5o+AD/zo6QBx0XzgATDN8Kkc4AEwzfDMQQsshuStK8RHhGciAgW2/iD8QgoZTGNBwh5E95kqlNfAkjwL/k20uq1CTXNtmlg4wzWsM=" --app n8n-dispatch-icy-surf-388

echo "Setting database and telemetry secrets..."
fly secrets set DB_POSTGRESDB_HOST=ep-soft-wave-ab54c4oo-pooler.eu-west-2.aws.neon.tech --app n8n-dispatch-icy-surf-388
fly secrets set DB_POSTGRESDB_PORT=5432 --app n8n-dispatch-icy-surf-388
fly secrets set DB_POSTGRESDB_DATABASE=n8n_dispatch --app n8n-dispatch-icy-surf-388
fly secrets set DB_POSTGRESDB_USER=neondb_owner --app n8n-dispatch-icy-surf-388
fly secrets set DB_POSTGRESDB_PASSWORD="npg_4vSDZqJiOaC1" --app n8n-dispatch-icy-surf-388
fly secrets set N8N_DIAGNOSTICS_ENABLED=false --app n8n-dispatch-icy-surf-388

echo "Restarting n8n app to load new secrets..."
fly apps restart n8n-dispatch-icy-surf-388

echo "Done. Access n8n at https://n8n-dispatch-icy-surf-388.fly.dev and import the workflow from automated_volume_cleanup_workflow.json"