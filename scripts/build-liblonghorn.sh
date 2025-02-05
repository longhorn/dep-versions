#!/bin/bash
set -euo pipefail

MAIN_DIR=$(dirname $(dirname $(realpath $0)))

REPO_OVERRIDE="$1"
COMMIT_ID_OVERRIDE="$2"
SRC_DIR="/usr/src/liblonghorn"

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# Fetch repo and commit ID from versions.json, with optional overrides
LIBLONGHORN_REPO=$(jq -r '.["liblonghorn"].repo' ${MAIN_DIR}/versions.json)
LIBLONGHORN_COMMIT_ID=$(jq -r '.["liblonghorn"].commit' ${MAIN_DIR}/versions.json)

# Apply overrides if provided
if [[ -n "$REPO_OVERRIDE" ]]; then
    LIBLONGHORN_REPO="$REPO_OVERRIDE"
fi

if [[ -n "$COMMIT_ID_OVERRIDE" ]]; then
    LIBLONGHORN_COMMIT_ID="$COMMIT_ID_OVERRIDE"
fi

# Clone the repository
git clone "$LIBLONGHORN_REPO" "$SRC_DIR"

# Checkout the specific commit
cd "$SRC_DIR"
git checkout "$LIBLONGHORN_COMMIT_ID"

# Build and install
make
make install
