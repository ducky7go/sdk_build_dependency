#!/usr/bin/env bash
set -euo pipefail

# Resolves repo root and .env location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing .env at ${ENV_FILE}. Add MANAGED_SOURCE_DIR pointing to the source Managed folder." >&2
  exit 1
fi

# Load environment variables from .env
set -o allexport
source "${ENV_FILE}"
set +o allexport

: "${MANAGED_SOURCE_DIR:?Set MANAGED_SOURCE_DIR in .env pointing to the source Managed folder}"

SOURCE_DIR="${MANAGED_SOURCE_DIR%/}"
TARGET_DIR="${REPO_ROOT}/Managed"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "Source directory not found: ${SOURCE_DIR}" >&2
  exit 1
fi

mkdir -p "${TARGET_DIR}"

# Clear existing Managed contents before copying
find "${TARGET_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

# Copy new contents in
rsync -av --delete "${SOURCE_DIR}/" "${TARGET_DIR}/"

echo "Managed contents synced from ${SOURCE_DIR} to ${TARGET_DIR}"