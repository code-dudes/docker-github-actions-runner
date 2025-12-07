#!/bin/bash
set -e

cd /actions-runner

# Configure only if not already configured
if [ ! -f ".runner" ]; then
  if [ -z "$GITHUB_OWNER" ]; then
    echo "Error: GITHUB_OWNER is not set. Exiting."
    exit 1
  fi

  # RUNNER_TOKEN is required only for the initial configuration
  if [ -z "$RUNNER_TOKEN" ]; then
    echo "Error: RUNNER_TOKEN is not set. Exiting."
    exit 1
  fi

  if [ -n "$GITHUB_REPOSITORY" ]; then
    REPO_URL="https://github.com/${GITHUB_OWNER}/${GITHUB_REPOSITORY}"
  else
    REPO_URL="https://github.com/${GITHUB_OWNER}"
  fi

  # Use provided name or default to hostname
  RUNNER_NAME=${RUNNER_NAME:-"docker-runner-$(hostname)"}

  # Build config command
  CONFIG_CMD=("./config.sh" --url "${REPO_URL}" --token "${RUNNER_TOKEN}" --name "${RUNNER_NAME}" --work "_work" --unattended)

  if [ -n "$RUNNER_LABELS" ]; then
    CONFIG_CMD+=("--labels" "${RUNNER_LABELS}")
  fi

  echo "Configuring the runner..."
  "${CONFIG_CMD[@]}"
fi

echo "Starting the runner..."
exec ./run.sh
