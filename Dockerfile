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
    # docker-cli is not available on ubuntu, so we install docker.io
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Prepare for runner download
ARG TARGETARCH
ARG RUNNER_VERSION

# Create a directory for the runner
WORKDIR /actions-runner

# Download and install the runner
# This 'case' statement (like a switch) maps Docker's TARGETARCH (e.g., "amd64")
# to the name used in the runner's download URL (e.g., "x64").
RUN echo "Building for architecture: ${TARGETARCH}" && \
    case ${TARGETARCH} in \
        "amd64") RUNNER_ARCH="x64" ;; \
        "arm64") RUNNER_ARCH="arm64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    echo "Downloading runner for ${RUNNER_ARCH}..." && \
    curl -o actions-runner.tar.gz -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz" && \
    tar xzf ./actions-runner.tar.gz && \
    rm actions-runner.tar.gz && \
    # The dependency script should now work on Ubuntu
    ./bin/installdependencies.sh

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
