#!/bin/bash

script="$(readlink -f "${BASH_SOURCE[0]}")"
dir="$(dirname "$script")"

$dir/run.sh bash -c 'cmake --preset=unix-hip -S /src && cmake --build /src/unix-hip -j 8'
