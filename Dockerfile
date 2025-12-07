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
RUN export RUNNER_ARCH=$(case ${TARGETARCH} in "amd64") echo -n "x64" ;; "arm64") echo -n "arm64" ;; *) echo -n "unsupported" ;; esac) && \
    if [ "$RUNNER_ARCH" = "unsupported" ]; then echo "Unsupported architecture: ${TARGETARCH}" && exit 1; fi && \
    echo "Building for architecture: ${TARGETARCH} (${RUNNER_ARCH})" && \
    echo "Downloading runner v${RUNNER_VERSION} for ${RUNNER_ARCH}..." && \
    curl -o actions-runner.tar.gz -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz" && \
    tar xzf ./actions-runner.tar.gz && \
    rm actions-runner.tar.gz && \
    ./bin/installdependencies.sh


# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
