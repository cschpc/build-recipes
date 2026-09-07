#!/usr/bin/env bash
# Generated with Claude
# 
# Run the Runko build container with your checkout mounted at /src.
#
#   ./run.sh                 # drop into a shell in the container
#   ./run.sh pip install .   # run a one-off command instead of a shell
#
# Build artifacts are stored in the venv volume (persists across runs) and any files
# written under /src exist in the directory mounted from host.
#
# How this script behaves: builds the image on first run if it's missing,
# mounts current directory at /src,
# runs as user's uid,
# and keeps /opt/venv in a named volume so the installed build survives --rm between runs.
#
# Because /opt/venv is a volume, changes you make to it (installed packages)
# outlive the container but are also not reset by rebuilding the image.
# If you rebuild runko-build with different Python deps and want a clean venv,
# delete the volume first with `docker volume rm runko-venv`.

set -euo pipefail

IMAGE=runko-build          # image tag (built from ./Dockerfile if missing)
SRC="$PWD"                 # host directory to mount at /src (default: cwd)
VENV_VOL=runko-venv        # named volume for /opt/venv, so builds persist

# Build the image if it doesn't exist
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "Building $IMAGE ..."
  docker build -t "$IMAGE" "$(dirname "$0")"
fi

# Run as current user's uid/gid so files aren't root-owned; HOME=/tmp is writable.
# --rm: the container is disposable; state lives in the mount and the volume.
exec docker run --rm -it \
  --user "$(id -u):$(id -g)" -e HOME=/tmp \
  -v "$SRC:/src" -w /src \
  -v "$VENV_VOL:/opt/venv" \
  "$IMAGE" "${@:-bash}"
