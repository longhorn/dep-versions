#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

MAIN_DIR=$(dirname $(dirname $(realpath $0)))

REPO_OVERRIDE="$1"
COMMIT_ID_OVERRIDE="$2"
SRC_DIR="/usr/src/nvme-cli"
BUILD_DIR="$SRC_DIR/.build"

# Fetch repo and commit ID from versions.json, with optional overrides
NVME_CLI_REPO=$(jq -r '.["nvme-cli"].repo' ${MAIN_DIR}/versions.json)
NVME_CLI_COMMIT_ID=$(jq -r '.["nvme-cli"].commit' ${MAIN_DIR}/versions.json)

# Apply overrides if provided
if [[ -n "$REPO_OVERRIDE" ]]; then
    NVME_CLI_REPO="$REPO_OVERRIDE"
fi

if [[ -n "$COMMIT_ID_OVERRIDE" ]]; then
    NVME_CLI_COMMIT_ID="$COMMIT_ID_OVERRIDE"
fi

# Clone the repository
git clone "$NVME_CLI_REPO" "$SRC_DIR"

# Checkout the specific commit
cd "$SRC_DIR"
git checkout "$NVME_CLI_COMMIT_ID"

# Configure, build, and install
meson setup --force-fallback-for=libnvme "$BUILD_DIR"
meson compile -C "$BUILD_DIR"
meson install -C "$BUILD_DIR"
