#!/usr/bin/env bash
set -euo pipefail

# Builds the FastAPI container image locally using the root Dockerfile.

IMAGE_NAME="${IMAGE_NAME:-your-registry/kubestate-recovery-lab-api:phase-2}"

docker build -t "${IMAGE_NAME}" .
echo "Built ${IMAGE_NAME}"
