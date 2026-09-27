#!/usr/bin/env bash
# Git Hook for Issue IDs
# Adds to the top of your commit message the issue ID, based on the prefix of the current branch `feature/AWG-562-add-linter`
# Example: `Add SwiftLint -> `AWG-562 Add SwiftLint
# Original source: https://github.com/aitemr/awesome-git-hooks/blob/master/prepare-commit-msg/prepare-commit-msg-jira
# shellcheck disable=SC2155

extract_jira_issue_id() {
  grep -Eom1 '[A-Z0-9]{1,10}-[A-Z0-9]+' <<< "$1"
}

extract_common_issue_id() {
  local id
  id=$(grep -Eom1 '[1-9][0-9]*' <<< "$1")
  readonly id

  if [[ -n "$id" ]]
  then
    echo "(#$id)"
  fi
}

extract_issue_id() {
  local origin && origin=$(git remote get-url origin) && readonly origin
  case "$origin" in
    *bitbucket*)
      extract_jira_issue_id "$@"
      ;;
    *)
      extract_common_issue_id "$@"
      ;;
  esac
}

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <commit_file>" >&2
  exit 1
fi

# Skip merge commits
case "$2" in
  merge)   exit 0 ;;                 # Skip merge commits
  squash)  exit 0 ;;                 # Skip squashes
  commit)  ;;                        # --amend or rebase -i
  message|template) ;;               # -m or -t
  *) ;;                              # Normal edit
esac

readonly current_branch="$(git branch --show-current)"
if [[ "$current_branch" == '' ]]; then
  # We're not currently on a branch; nothing to do
  exit 0
fi

declare -ra BRANCHES_TO_SKIP="${BRANCHES_TO_SKIP:=("master" "main" "develop" "test")}"
for branch in "${BRANCHES_TO_SKIP[@]}"; do
  if [[ "$branch" == "$current_branch" ]]; then
    echo "Branch \`$branch\` is on ignored branches list; not checking issue number"
    exit 0
  fi
done

readonly commit_file="$1"
readonly commit_msg=$(cat "$1")

if [[ "$commit_msg" == "fixup"* ]]; then
  echo "Fixup commit; not checking issue number"
  exit 0
fi

# Extract the ID
readonly id_in_branch="$(extract_issue_id "$current_branch")"
readonly first_line_in_msg="$(echo "$commit_msg" | head -1)"
readonly id_in_msg="$(extract_issue_id "$first_line_in_msg")"

if [[ "$id_in_msg" == "" ]] && [[ "$id_in_branch" == "" ]]; then
  # No ID to match against
  exit 0
fi

if [[ "$id_in_msg" == "$id_in_branch" ]]; then
  echo "Issue ID '$id_in_branch' already found in commit message."
elif [[ "$id_in_msg" != "" ]]; then
  echo "WARNING: Commit message Issue ID ($id_in_msg) is not equal to current branch Issue ID ($id_in_branch)" >&2
  echo "         Commit message will contain both" >&2
  echo "$id_in_branch $commit_msg" > "$commit_file"
else
  echo "Issue ID '$id_in_branch', matched in current branch name, prepended to commit message."
  echo "$id_in_branch $commit_msg" > "$commit_file"
fi
