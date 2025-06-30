#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

MAIN_DIR=$(dirname $(dirname $(realpath $0)))

REPO_OVERRIDE="$1"
COMMIT_ID_OVERRIDE="$2"
SRC_DIR="/usr/src/json-c"
BUILD_DIR="$SRC_DIR/.build"

# Fetch repo and commit ID from versions.json, with optional overrides
LIBJSONC_REPO=$(jq -r '.["libjsonc"].repo' ${MAIN_DIR}/versions.json)
LIBJSONC_COMMIT_ID=$(jq -r '.["libjsonc"].commit' ${MAIN_DIR}/versions.json)

# Apply overrides if provided
if [[ -n "$REPO_OVERRIDE" ]]; then
    LIBJSONC_REPO="$REPO_OVERRIDE"
fi

if [[ -n "$COMMIT_ID_OVERRIDE" ]]; then
    LIBJSONC_COMMIT_ID="$COMMIT_ID_OVERRIDE"
fi

# Clone the repository
git clone "$LIBJSONC_REPO" "$SRC_DIR"

# Checkout the specific commit
cd "$SRC_DIR"
git checkout "$LIBJSONC_COMMIT_ID"

# Create and enter the build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Build and install
# CMAKE_POLICY_VERSION_MINIMUM is used to ensure compatibility with CMake 3.5 and above
cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ..
make
make install
