# homedaycare-web

Static visit-card website for a home daycare service. It promotes care for children ages 1–3, meals 1–3 times per day, music teacher activities, painting/creative play, and an 8 AM–5 PM care window.

## Runtime contract

- Shared static root: `web/`
- Docker dev image: `snkd92/homedaycare-web:dev`
- Local source preview: `./deploy-source.sh`
- Published dev image preview: `./deploy-local.sh`
- Verification: `./verify-site.sh http://localhost:8095`
- Production: Azure Static Web Apps in resource group `homedaycare-web`
- Domain: none configured yet

## Files

- `web/index.html` — public website
- `web/styles.css` — responsive design
- `web/app.js` — reserved lightweight script marker for future inquiry features
- `web/health.json` — health endpoint
- `web/staticwebapp.config.json` — Azure Static Web Apps config
- `Dockerfile` and `nginx.conf` — Nginx static runtime
- `.github/workflows/docker-dev.yml` — manual Docker Hub dev image build/publish
- `.github/workflows/azure-prod.yml` — manual Azure production deploy

## Local source preview

```bash
./deploy-source.sh
./verify-site.sh http://localhost:8095
```

## Published dev image preview

```bash
./deploy-local.sh
./verify-site.sh http://localhost:8095
```

## Production deploy

The Azure workflow is manual and requires the `production` environment plus the `DEPLOY-PROD` confirmation input.
