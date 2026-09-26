#!/usr/bin/env bash

declare -r staged_files=( "$@" )

gersemi --check "${staged_files[@]}"
exit $?
