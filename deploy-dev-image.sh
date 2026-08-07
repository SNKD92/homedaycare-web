#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-snkd92/homedaycare-web:dev}"
CONTAINER_NAME="${CONTAINER_NAME:-homedaycare-web-site}"
PORT="${PORT:-8095}"
BIND_ADDR="${BIND_ADDR:-127.0.0.1}"
AZURE_KEY_VAULT_NAME="${AZURE_KEY_VAULT_NAME:-deniskachar-ci-kv}"

cd "$(dirname "$0")"

echo "Repository path: $(pwd)"
echo "Git branch:      $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
echo "Git commit:      $(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
echo "Origin/main:     $(git rev-parse --short origin/main 2>/dev/null || echo unknown)"
echo "Published image: ${IMAGE_NAME}"
echo "This previews the published Docker image; it does not build from this checkout."

if ! docker pull "${IMAGE_NAME}"; then
  echo "Initial docker pull failed. Trying Docker Hub login from Azure Key Vault ${AZURE_KEY_VAULT_NAME}." >&2
  if command -v az >/dev/null 2>&1; then
    username="$(az keyvault secret show --vault-name "$AZURE_KEY_VAULT_NAME" --name dockerhub-username --query value -o tsv 2>/dev/null || true)"
    token="$(az keyvault secret show --vault-name "$AZURE_KEY_VAULT_NAME" --name dockerhub-token --query value -o tsv 2>/dev/null || true)"
    if [ -n "$username" ] && [ -n "$token" ]; then
      printf '%s' "$token" | docker login --username "$username" --password-stdin
      docker pull "${IMAGE_NAME}"
    else
      echo "Docker Hub credentials not available from Key Vault." >&2
      exit 1
    fi
  else
    exit 1
  fi
fi

docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
docker run -d --name "${CONTAINER_NAME}" -p "${BIND_ADDR}:${PORT}:80" "${IMAGE_NAME}" >/dev/null
for i in $(seq 1 20); do
  if curl -fsS "http://${BIND_ADDR}:${PORT}/health.json" >/dev/null; then break; fi
  if [ "$i" = 20 ]; then docker logs "${CONTAINER_NAME}"; exit 1; fi
  sleep 1
done
for route in /health.json /; do
  curl -fsS "http://${BIND_ADDR}:${PORT}${route}" >/dev/null
  echo "  ok ${route}"
done

echo "Done. Published-image URL: http://${BIND_ADDR}:${PORT}/"
