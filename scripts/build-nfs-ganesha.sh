#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

MAIN_DIR=$(dirname $(dirname $(realpath $0)))

REPO_OVERRIDE="$1"
COMMIT_ID_OVERRIDE="$2"
SRC_DIR="/nfs-ganesha"

# Fetch repo and commit ID from versions.json, with optional overrides
NFS_GANESHA_REPO=$(jq -r '.["nfs-ganesha"].repo' ${MAIN_DIR}/versions.json)
NFS_GANESHA_COMMIT_ID=$(jq -r '.["nfs-ganesha"].commit' ${MAIN_DIR}/versions.json)
NTIRPC_REPO=$(jq -r '.["ntirpc"].repo' ${MAIN_DIR}/versions.json)
NTIRPC_COMMIT_ID=$(jq -r '.["ntirpc"].commit' ${MAIN_DIR}/versions.json)

# Apply overrides if provided
if [[ -n "$REPO_OVERRIDE" ]]; then
    NFS_GANESHA_REPO="$REPO_OVERRIDE"
fi

if [[ -n "$COMMIT_ID_OVERRIDE" ]]; then
    NFS_GANESHA_COMMIT_ID="$COMMIT_ID_OVERRIDE"
fi

# Clone and checkout repositories
git clone "$NFS_GANESHA_REPO" /nfs-ganesha
cd /nfs-ganesha
git checkout "$NFS_GANESHA_COMMIT_ID"
rm -rf src/libntirpc
git clone "$NTIRPC_REPO" src/libntirpc
git -C src/libntirpc checkout "$NTIRPC_COMMIT_ID"
git -C src/libntirpc submodule update --init --recursive

# Build and install
export CC="/usr/bin/gcc" CXX="/usr/bin/g++"
mkdir -p /usr/local
# CMAKE_POLICY_VERSION_MINIMUM is used to ensure compatibility with CMake 3.5 and above
cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -DCMAKE_BUILD_TYPE=Release -DBUILD_CONFIG=vfs_only \
      -DUSE_DBUS=OFF -DUSE_NLM=OFF -DUSE_RQUOTA=OFF -DUSE_9P=OFF -D_MSPAC_SUPPORT=OFF -DRPCBIND=OFF \
      -DUSE_RADOS_RECOV=OFF -DRADOS_URLS=OFF -DUSE_FSAL_VFS=ON -DUSE_FSAL_XFS=OFF \
      -DUSE_FSAL_PROXY_V4=OFF -DUSE_FSAL_PROXY_V3=OFF -DUSE_FSAL_LUSTRE=OFF -DUSE_FSAL_LIZARDFS=OFF \
      -DUSE_FSAL_KVSFS=OFF -DUSE_FSAL_CEPH=OFF -DUSE_FSAL_GPFS=OFF -DUSE_FSAL_PANFS=OFF -DUSE_FSAL_GLUSTER=OFF \
      -DUSE_GSS=NO -DHAVE_ACL_GET_FD_NP=ON -DHAVE_ACL_SET_FD_NP=ON \
      -DUSE_MONITORING=OFF \
      -DCMAKE_INSTALL_PREFIX=/usr/local src/
make -j$(nproc)
make install

# Set up additional directories and copy configuration
mkdir -p /ganesha-extra/etc/dbus-1/system.d
cp src/scripts/ganeshactl/org.ganesha.nfsd.conf /ganesha-extra/etc/dbus-1/system.d/
