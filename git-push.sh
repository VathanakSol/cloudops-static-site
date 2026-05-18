#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

REMOTE="origin"
BRANCH=""
MESSAGE="Update repository"

usage() {
  cat <<EOF
Usage: $(basename "$0") [-r remote] [-b branch] [-m message]

Options:
  -r remote    Git remote to push to (default: origin)
  -b branch    Branch to push (default: current branch)
  -m message   Commit message (default: 'Update repository')
  -h           Show this help message
EOF
}

while getopts ":r:b:m:h" opt; do
  case "$opt" in
    r) REMOTE="$OPTARG" ;;
    b) BRANCH="$OPTARG" ;;
    m) MESSAGE="$OPTARG" ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

if [ ! -d .git ]; then
  echo "Error: This directory is not a Git repository. Run the script from the repo root." >&2
  exit 1
fi

if [ -z "$BRANCH" ]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

printf 'Remote: %s\n' "$REMOTE"
printf 'Branch: %s\n' "$BRANCH"
printf 'Commit message: %s\n' "$MESSAGE"

if [ -z "$(git status --porcelain)" ]; then
  echo "No changes detected. Nothing to commit or push."
  exit 0
fi

git add -A

git commit -m "$MESSAGE"

git push "$REMOTE" "$BRANCH"

echo "Successfully pushed changes to $REMOTE/$BRANCH."