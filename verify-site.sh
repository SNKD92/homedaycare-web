#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://localhost:8095}"
BASE_URL="${BASE_URL%/}"
require() {
  local route="$1" needle="$2"
  body="$(curl -fsS "${BASE_URL}${route}")"
  if ! grep -Fq "$needle" <<<"$body"; then
    echo "Missing '${needle}' from ${route}" >&2
    exit 1
  fi
  echo "ok ${route} contains ${needle}"
}
curl -fsS "${BASE_URL}/health.json" | grep -Fq 'homedaycare-web'
require / 'Home Daycare'
require / 'children from 1 to 3 years old'
require / 'Meals 1–3 times a day'
require / 'Music teacher'
require / 'Painting and creativity'
require / '8 AM to 5 PM'
require /styles.css ':root'
require /app.js 'HOMEDAYCARE_WEB'
echo "Verification passed for ${BASE_URL}"
