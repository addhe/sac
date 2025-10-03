#!/usr/bin/env bash
set -euo pipefail

# Simple deploy helper for Cloud Run
# - Builds the Docker image
# - Pushes to Artifact Registry
# - Deploys to Cloud Run
#
# Usage:
#   ./deploy.sh
#
# Optional env overrides:
#   PROJECT_ID (default: your-gcp-project-id)
#   REGION     (default: us-central1)
#   SERVICE    (default: stock-average-calculator)
#   REPO       (default: stock-average-calculator)

PROJECT_ID=${PROJECT_ID:-your-gcp-project-id}
REGION=${REGION:-us-central1}
SERVICE=${SERVICE:-stock-average-calculator}
REPO=${REPO:-stock-average-calculator}
# Platform target for Docker build. Cloud Run runs linux; prefer amd64 for maximum compatibility.
PLATFORM=${PLATFORM:-linux/amd64}

IMAGE_PATH="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${SERVICE}:latest"

echo "[INFO] Project: ${PROJECT_ID}"
echo "[INFO] Region:  ${REGION}"
echo "[INFO] Service: ${SERVICE}"
echo "[INFO] Image:   ${IMAGE_PATH}"

if [ "${PROJECT_ID}" == "your-gcp-project-id" ]; then
    echo "[ERROR] Please set the PROJECT_ID environment variable or change the default value in the script."
    exit 1
fi

echo "[STEP] Configuring gcloud project"
gcloud config set project "${PROJECT_ID}" >/dev/null

echo "[STEP] Enabling required services (idempotent)"
gcloud services enable artifactregistry.googleapis.com run.googleapis.com >/dev/null

echo "[STEP] Ensuring Artifact Registry repo exists (idempotent)"
if ! gcloud artifacts repositories describe "${REPO}" --location="${REGION}" >/dev/null 2>&1; then
  gcloud artifacts repositories create "${REPO}" \
    --repository-format=docker \
    --location="${REGION}" \
    --description="Stock Average Calculator images"
fi

echo "[STEP] Configuring Docker auth for Artifact Registry"
gcloud auth configure-docker "${REGION}-docker.pkg.dev" -q >/dev/null

echo "[STEP] Building image (platform: ${PLATFORM})"
docker build --platform="${PLATFORM}" -t "${IMAGE_PATH}" .

echo "[STEP] Pushing image"
docker push "${IMAGE_PATH}"

echo "[STEP] Deploying to Cloud Run"
DEPLOY_ARGS=(
  "${SERVICE}"
  --image "${IMAGE_PATH}"
  --platform managed
  --region "${REGION}"
  --allow-unauthenticated
  --port=8080
  --timeout=300s
)

gcloud run deploy "${DEPLOY_ARGS[@]}" || DEPLOY_FAILED=$?

if [[ -n "${DEPLOY_FAILED:-}" ]]; then
  echo "[WARN] Deploy command reported a failure (code=${DEPLOY_FAILED}). Collecting diagnostics..."
fi

echo "[DONE] Deployment initiated. Fetching recent logs (last 50 lines)"
# This requires gcloud beta; install if missing
if ! gcloud beta --help >/dev/null 2>&1; then
  echo "[INFO] Installing gcloud beta components"
  yes | gcloud components install beta >/dev/null || true
fi

gcloud beta run services logs read "${SERVICE}" --region="${REGION}" --limit=50 || true

echo "[INFO] Latest revisions:"
gcloud run revisions list --region="${REGION}" --service="${SERVICE}" --limit=5 || true

echo "[TIP] To update the service later (e.g., change environment variables):"
echo "  gcloud run services update ${SERVICE} --region=${REGION} --update-env-vars=KEY=VALUE"
