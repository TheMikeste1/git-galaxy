#!/usr/bin/env bash

staged_files=( "$@" )
path="$PWD"
# Explicitly add the full path to files in case we change directories
staged_files=( "${staged_files[@]/#/$path/}" )

# Find a suppressions file, if it exists
suppression_file=
while [ "$path" != "" ]; do
  if [ -e "$path/cppcheck-suppressions.txt" ]; then
    suppression_file="--suppressions-list=$path/cppcheck-suppressions.txt"
    cd "$path" || exit 1

  fi
  path="${path%/*}" # Strip the last directory component
done
readonly suppression_file

# Make paths relative now that we know where we are
staged_files=("${staged_files[@]#$PWD/}")
readonly staged_files

mkdir -p .cache/cppcheck || exit 1
# shellcheck disable=SC2086
cppcheck \
  "$suppression_file" \
  --enable=warning,performance,portability,information \
  --disable=missingInclude \
  --suppress=unknownMacro \
  --suppress=checkersReport \
  --suppress=normalCheckLevelMaxBranches \
  --suppress=unmatchedSuppression \
  --language=c++ \
  --cppcheck-build-dir=.cache/cppcheck \
  --error-exitcode=1 \
  --inline-suppr \
  --force \
  --library=googletest \
  -j \
  8 \
  "${staged_files[@]}"
exit $?
