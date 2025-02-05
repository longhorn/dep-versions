#!/bin/bash
set -euo pipefail

MAIN_DIR=$(dirname $(dirname $(realpath $0)))

REPO_OVERRIDE="$1"
COMMIT_ID_OVERRIDE="$2"
INSTALL_PATH="/usr/local/bin/go-spdk-helper"
SRC_DIR="/usr/src/go-spdk-helper"

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# Fetch repo and commit ID from versions.json, with optional overrides
GO_SPDK_HELPER_REPO=$(jq -r '.["go-spdk-helper"].repo' ${MAIN_DIR}/versions.json)
GO_SPDK_HELPER_COMMIT_ID=$(jq -r '.["go-spdk-helper"].commit' ${MAIN_DIR}/versions.json)

# Apply overrides if provided
if [[ -n "$REPO_OVERRIDE" ]]; then
    GO_SPDK_HELPER_REPO="$REPO_OVERRIDE"
fi

if [[ -n "$COMMIT_ID_OVERRIDE" ]]; then
    GO_SPDK_HELPER_COMMIT_ID="$COMMIT_ID_OVERRIDE"
fi

# Clone the repository
git clone "$GO_SPDK_HELPER_REPO" "$SRC_DIR"

# Checkout the specific commit
cd "$SRC_DIR"
git checkout "$GO_SPDK_HELPER_COMMIT_ID"

# Build and install
go build
install -m 755 go-spdk-helper "$INSTALL_PATH"
