# Use a supported base image like Ubuntu
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for the runner and for the docker build context
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    tar \
    git \
    docker.io \
    ca-certificates \
    libicu70 \
    libkrb5-3 \
    liblttng-ust1 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Prepare for runner download
ARG TARGETARCH
ARG RUNNER_VERSION

# Create a directory for the runner
WORKDIR /actions-runner

# Download and install the runner
RUN \
  # Map Docker arch → GitHub runner arch
  case "$TARGETARCH" in \
      amd64) RUNNER_ARCH="x64" ;; \
      arm64) RUNNER_ARCH="arm64" ;; \
      *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
  esac && \
  echo "Building for architecture: ${TARGETARCH} (${RUNNER_ARCH})" && \
  RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz" && \
  echo "Downloading: $RUNNER_URL" && \
  curl -fsSL -o actions-runner.tar.gz "$RUNNER_URL" && \
  tar xzf actions-runner.tar.gz && \
  rm actions-runner.tar.gz && \
  ./bin/installdependencies.sh


# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
