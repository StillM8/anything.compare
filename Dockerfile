# syntax=docker/dockerfile:1
FROM elixir:1.17 AS base

# Set environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies: Node.js, build tools, PostgreSQL client
RUN apt-get update -qq && \
    apt-get install -y -qq \
      curl \
      ca-certificates \
      gnupg \
      build-essential \
      inotify-tools \
      git \
      libssl-dev \
      libpq-dev \
      postgresql-client \
    && \
    # Install Node.js via NodeSource
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y -qq nodejs && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install common global tools
RUN npm install -g npm@latest && \
    npm cache clean --force

# Install Hex and Rebar for Elixir
RUN mix local.hex --force && \
    mix local.rebar --force

# Create working directory
WORKDIR /app
