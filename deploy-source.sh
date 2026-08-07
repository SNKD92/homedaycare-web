#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="homedaycare-web"
IMAGE_NAME="snkd92/homedaycare-web:source"
CONTAINER_NAME="homedaycare-web-site"
PORT="${PORT:-8095}"
BIND_ADDR="${BIND_ADDR:-127.0.0.1}"

cd "$(dirname "$0")"

echo "Repository path: $(pwd)"
echo "Git branch:      $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
echo "Git commit:      $(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
echo "Origin/main:     $(git rev-parse --short origin/main 2>/dev/null || echo unknown)"
echo "[1/5] Building image from current checkout: ${IMAGE_NAME}"
docker build -t "${IMAGE_NAME}" .

echo "[2/5] Replacing existing container: ${CONTAINER_NAME}"
docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

echo "[3/5] Starting container on ${BIND_ADDR}:${PORT} -> 80"
docker run -d --name "${CONTAINER_NAME}" -p "${BIND_ADDR}:${PORT}:80" "${IMAGE_NAME}" >/dev/null

echo "[4/5] Waiting for nginx"
for i in $(seq 1 20); do
  if curl -fsS "http://${BIND_ADDR}:${PORT}/health.json" >/dev/null; then break; fi
  if [ "$i" = 20 ]; then docker logs "${CONTAINER_NAME}"; exit 1; fi
  sleep 1
done

echo "[5/5] Smoke-testing routes"
for route in /health.json /; do
  curl -fsS "http://${BIND_ADDR}:${PORT}${route}" >/dev/null
  echo "  ok ${route}"
done

echo "Done. Local source URL: http://${BIND_ADDR}:${PORT}/"
