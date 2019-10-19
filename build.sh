#!/usr/bin/env bash

set -eu

# Runs docker container.
# Main purpose is to use on Windows but can be used by all, especially to avoid
# installing required tooling (make, go, etc).
#
# Usage:
#
#   # will target host's OS and architecture
#   ./build.sh make build
#   ./build.sh make all
#
#   # override target OS/architecture
#   Z_GOOS=linux Z_GOARCH=amd ./build.sh make build
#   Z_GOOS=linux Z_GOARCH=amd ./build.sh make all
#
Z_GOOS="${Z_GOOS:-"$(go env GOOS)"}"
Z_GOARCH="${Z_GOARCH:-"$(go env GOARCH)"}"

DOCKER_IMAGE="golang:1.13"

cd "$(dirname "${BASH_SOURCE}")"

echo "Running in docker container ${DOCKER_IMAGE}..."

(
  set -x
  docker run \
    -it \
    --rm \
    -v "${PWD}:${PWD}":cached \
    -w ${PWD} \
    -e Z_GOOS="${Z_GOOS}" \
    -e Z_GOARCH="${Z_GOARCH}" \
    -e Z_GOBIN="${PWD}/bin_tools/linux_amd64" \
    ${DOCKER_IMAGE} \
    "$@"
)

