#!/usr/bin/env bash

declare -r staged_files=( "$@" )
clang-format -style=file --dry-run --Werror "${staged_files[@]}" || (clang-format -style=file -i "${staged_files[@]}" && false)
exit $?
