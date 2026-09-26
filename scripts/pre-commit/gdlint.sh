#!/usr/bin/env bash

declare -r staged_files=( "$@" )

gdlint "${staged_files[@]}"
exit $?
