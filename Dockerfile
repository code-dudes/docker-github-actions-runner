FROM alpine:latest

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    tar \
    git \
    docker-cli \
    libicu \
    lttng-ust \
    krb5-libs

# Prepare for runner download
ARG TARGETARCH
ARG RUNNER_VERSION="2.317.0" # Default version

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
    ./bin/installdependencies.sh



# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
