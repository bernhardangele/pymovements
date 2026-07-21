# syntax=docker/dockerfile:1.7
FROM mcr.microsoft.com/devcontainers/python:3-3.12-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# 1. Multi-arch APT Caching
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    r-base r-base-dev \
    libcurl4-openssl-dev libssl-dev libxml2-dev libcairo2-dev \
    git-annex \
    curl ca-certificates gnupg \
    fonts-dejavu \
    && install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && chmod a+r /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs

# 2. Architecture-agnostic Posit Binary URL
ARG CRAN_SNAPSHOT=https://packagemanager.posit.co/cran/__linux__/bookworm/2026-07-20
RUN echo "options(repos = c(CRAN = '${CRAN_SNAPSHOT}'))" >> /usr/lib/R/etc/Rprofile.site \
    && Rscript -e "install.packages(c('tidyverse','data.table','jsonlite','arrow','reticulate','testthat'))"

# 3. Pull architecture-matched uv binary
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install DataLad globally
RUN uv tool install datalad --with datalad-osf
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /workspaces/pymovements