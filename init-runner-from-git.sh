#!/bin/bash -xe

# EC2 User Data script to clone a repo, configure, and launch a GitHub Actions runner.

# --- Configuration ---
# IMPORTANT: Replace these placeholder values.

# The URL to the Git repository containing your Dockerfile, docker-compose.yml, etc.
GIT_REPO_URL="https://github.com/your-user/actions-runner-docker.git"

# Runner configuration that will be written to a .env file
GITHUB_OWNER="your-github-org"
GITHUB_REPOSITORY="" # Optional: "your-repo". Leave empty for an org-level runner.
RUNNER_NAME="gh-actions-runner"
RUNNER_LABELS="ec2,linux,production" # Optional: comma-separated labels

# The RUNNER_TOKEN is handled separately as a secret. It must be a fresh,
# single-use registration token from GitHub.
# For production, fetch this from AWS Secrets Manager or Parameter Store.
RUNNER_TOKEN="YOUR_RUNNER_TOKEN"


# --- 1. System Update and Dependency Installation ---
echo "Updating system and installing dependencies..."
yum update -y
yum install -y docker git

# Install a specific version of Docker Compose for stability
DOCKER_COMPOSE_VERSION="1.29.2"
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


# --- 2. Start Docker Service ---
echo "Starting Docker service..."
systemctl enable docker
systemctl start docker
usermod -a -G docker ec2-user # Allow ec2-user to run docker commands


# --- 3. Clone Repo and Configure ---
echo "Cloning repository and creating .env file..."
PROJECT_DIR="/opt/actions-runner"
git clone "${GIT_REPO_URL}" "${PROJECT_DIR}"
cd "${PROJECT_DIR}"

# Create a .env file for Docker Compose to use.
# This provides the configuration to the docker-compose.yml file.
cat <<EOF > .env
GITHUB_OWNER=${GITHUB_OWNER}
GITHUB_REPOSITORY=${GITHUB_REPOSITORY}
RUNNER_NAME=${RUNNER_NAME}
RUNNER_LABELS=${RUNNER_LABELS}
EOF


# --- 4. Launch the Runner ---
echo "Launching the GitHub Actions runner container..."

# Export the token so docker-compose can access it from the environment.
export RUNNER_TOKEN

# Run docker-compose as the ec2-user to avoid permission issues.
su - ec2-user -c "cd ${PROJECT_DIR} && /usr/local/bin/docker-compose up -d --build"

echo "GitHub Actions runner setup complete."
