#!/bin/bash

# Usage:
# ./scripts/build.sh [gzdoom parameters]

set -e

filename=./build/graveyard-$(git describe --abbrev=0 --tags).pk3

rm -f  $filename
zip -R $filename "*.md" "*.txt" "*.zs" "*.png"
gzdoom $filename "$@"
