#!/usr/bin/env bash

set -euo pipefail

# Configuration
REPO_OWNER="llunbot"
REPO_NAME="personal-feeds"
WORKFLOW_ID="feeds.yml"
DEFAULT_REF="main"
ENV_FILE="${TOKEN_ENV_FILE:-/root/.github-token.env}"

# 1. Load token from env file if GITHUB_TOKEN is not already in the environment
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  if [[ -f "$ENV_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$ENV_FILE"
  elif [[ -f "$HOME/.github-token.env" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.github-token.env"
  fi
fi

# 2. Validate token
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "Error: GITHUB_TOKEN is not set and could not be loaded from $ENV_FILE" >&2
  exit 1
fi

REF="${1:-$DEFAULT_REF}"

echo "Triggering workflow '$WORKFLOW_ID' for $REPO_OWNER/$REPO_NAME on ref '$REF'..."

# 3. Call GitHub API
HTTP_RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/workflows/${WORKFLOW_ID}/dispatches" \
  -d "{\"ref\":\"${REF}\"}")

HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed '$d')
HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tail -n 1)

# GitHub workflow dispatch returns HTTP 204 No Content on success
if [[ "$HTTP_STATUS" == "204" ]]; then
  echo "Successfully triggered workflow '$WORKFLOW_ID'!"
  exit 0
else
  echo "Failed to trigger workflow. HTTP Status: $HTTP_STATUS" >&2
  if [[ -n "$HTTP_BODY" ]]; then
    echo "Response: $HTTP_BODY" >&2
  fi
  exit 1
fi
