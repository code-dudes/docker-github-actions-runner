# Self-Hosted GitHub Actions Runner in Docker

This project provides a flexible and robust setup for running a self-hosted GitHub Actions runner inside a Docker container. The runner can access the host's Docker daemon, allowing it to execute Docker-based jobs.

## Features

- **Dockerized Runner**: Runs the official GitHub Actions runner in a lightweight Alpine Linux container.
- **Docker Socket Access**: Can build and run Docker containers as part of your CI/CD jobs by mounting the host's Docker socket.
- **Org & Repo Runners**: Easily configure the runner to be available at the organization or repository level.
- **Auto-Detect Architecture**: The Docker build automatically detects the host's CPU architecture (`x64` or `arm64`) and downloads the correct runner binary.
- **Configure-Once Logic**: The runner configures itself only on the first launch, making subsequent restarts much faster.
- **Persistent & Resilient**: Automatically restarts on container failure or system reboot thanks to a configurable restart policy.
- **Highly Configurable**: Customize the runner's name, labels, and version through the `docker-compose.yml` file.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Configuration

All configuration is handled in the `docker-compose.yml` file.

### 1. Runner Version

You can specify the version of the GitHub Actions runner to install by changing the `RUNNER_VERSION` build argument:

```yaml
services:
  actions-runner:
    build:
      context: .
      args:
        # You can change the runner version by modifying the value below
        RUNNER_VERSION: 2.317.0
```

### 2. Environment Variables

Set the following environment variables in `docker-compose.yml` to configure your runner:

```yaml
    environment:
      # --- Mandatory ---
      # Your GitHub username or organization name.
      - GITHUB_OWNER=
      # A GitHub registration token. This must be exported as a shell environment
      # variable (e.g., `export RUNNER_TOKEN=...`) before running docker-compose.
      - RUNNER_TOKEN=${RUNNER_TOKEN}

      # --- Optional ---
      # The repository name. If left blank, the runner will be registered for the organization.
      - GITHUB_REPOSITORY=
      # A custom name for the runner. If left blank, it defaults to the container's hostname.
      - RUNNER_NAME=
      # A comma-separated list of custom labels for the runner (e.g., "docker,production").
      - RUNNER_LABELS=
```

## Usage

1.  **Get a Registration Token from GitHub:**
    - **For an organization:** Navigate to `Settings > Actions > Runners` and click "New self-hosted runner".
    - **For a repository:** Navigate to `Settings > Actions > Runners` and click "New self-hosted runner".
    - Copy the registration token.

2.  **Configure `docker-compose.yml`:**
    - Open `docker-compose.yml` and fill in the `GITHUB_OWNER` and any optional variables (`GITHUB_REPOSITORY`, `RUNNER_NAME`, `RUNNER_LABELS`).

3.  **Export the Token:**
    - In your terminal, export the registration token as an environment variable. **Note:** This token is single-use and only needed for the first time the container is created.
    ```bash
    export RUNNER_TOKEN="YOUR_COPIED_TOKEN"
    ```

4.  **Build and Run the Container:**
    ```bash
    docker compose up -d --build
    ```

5.  **Verify the Runner:**
    - Check the container logs to see the runner starting up.
    ```bash
    docker compose logs -f
    ```
    - Navigate back to your GitHub runners settings page. You should see your new runner listed with a green "idle" status.

6.  **Stopping the Runner:**
    - To stop the runner and remove the container:
    ```bash
    docker compose down
    ```

## Advanced Configuration

### Graceful Shutdown

To ensure running jobs have time to complete before the container is stopped, you can set a `stop_grace_period` in the `docker-compose.yml` file. This is highly recommended for production use.

```yaml
services:
  actions-runner:
    # ... other settings
    stop_grace_period: 2m
```
