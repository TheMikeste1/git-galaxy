#!/usr/bin/env bash

set +e # We don't want grep failing to find an issue to crash callers

extract_jira_issue_id() {
  grep -Eom1 '[A-Z0-9]{1,10}-[A-Z0-9]+' <<< "$1"
}

extract_common_issue_id() {
  local id
  id=$(grep -Eom1 '[1-9][0-9]*' <<< "$1")
  readonly id

  if [[ -n "$id" ]]
  then
    echo "#$id"
  fi
}

origin="$(git remote get-url origin)" && readonly origin
case "$origin" in
  *bitbucket*)
    extract_jira_issue_id "$@"
    ;;
  *)
    extract_common_issue_id "$@"
    ;;
esac
exit 0
