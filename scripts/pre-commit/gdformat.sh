#!/usr/bin/env bash

declare -r staged_files=( "$@" )

if ! gdformat --check "${staged_files[@]}"; then
  gdformat "${staged_files[@]}"
  exit 1
fi

exit 0