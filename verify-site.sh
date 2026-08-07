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
require / 'children from 1 to 4 years old'
require / 'ages 1–4'
require / 'Meals 1–3 times a day'
require / 'Music teacher'
require / 'Painting and creativity'
require / 'Contact form'
require / 'parentName'
require / 'childAge'
require / 'healthy-meals.svg'
require / 'music-paint.svg'
require / 'playroom.svg'
require /styles.css 'picture-grid'
require /app.js 'buildInquiry'
require /assets/playroom.svg '<svg'
require /assets/music-paint.svg '<svg'
require /assets/healthy-meals.svg '<svg'
echo "Verification passed for ${BASE_URL}"
