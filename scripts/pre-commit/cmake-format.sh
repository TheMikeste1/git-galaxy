#!/usr/bin/env bash

declare -r staged_files=( "$@" )

gersemi --check "${staged_files[@]}" || (gersemi -i "${staged_files[@]}" && false)
exit $?
