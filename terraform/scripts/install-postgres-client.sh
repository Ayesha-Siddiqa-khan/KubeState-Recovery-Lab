#!/bin/bash
set -euo pipefail
echo "[TerraPilot][postgres] Installing PostgreSQL client tools"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y postgresql-client
psql --version
echo "[TerraPilot][postgres] PostgreSQL client setup complete"
