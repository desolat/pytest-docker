FROM python:3.7-slim-buster

RUN apt-get update && \
    apt-get install -y curl iproute2 dnsutils && \
    rm -rf /var/lib/apt/lists/*

# Docker CLI only: https://stackoverflow.com/a/43594065/47407
ARG DOCKER_VERSION=19.03.9
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz \
    && tar xzvf docker-${DOCKER_VERSION}.tgz --strip 1 \
        -C /usr/local/bin docker/docker \
    && rm docker-${DOCKER_VERSION}.tgz

ARG DOCKER_COMPOSE_VERSION=1.25.0
RUN curl -sSL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

RUN pip3 install \
    --no-cache-dir \
    -i https://nexus.kiebackpeter.kup/repository/pypi-all/simple \
    --trusted-host nexus.kiebackpeter.kup \
    --pre \
    pytest requests pydevd
