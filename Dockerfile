FROM elixir:1.10.3

ARG MIX_ENV=prod

ENV MIX_ENV=${MIX_ENV}

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y apt-utils build-essential inotify-tools postgresql-client

RUN curl -SL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs && \
    npm --global install yarn

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new 1.5.3

WORKDIR /app
COPY . /app/source

RUN cd /app/source && \
    MIX_ENV=${MIX_ENV} bin/local/reset-build && \
    MIX_ENV=${MIX_ENV} bin/local/reset-assets

# Production uses the following structure:
#
#   /app/build/     <- Directory where elixir release is built
#   /app/entrypoint <- Docker Entrypoint
#   /app/release/   <- Where the application release is run
#   /app/source/    <- Raw source code, used primarily for mix actions (create database, seed database, mix tasks)
#
RUN if [ "${MIX_ENV}" = "prod" ]; then \
  cp -pr /app/source /app/build && \
  cd /app/build && \
  cp bin/docker-prod/entrypoint /app/entrypoint && \
  bin/docker-prod/build-release && \
  mkdir -p /app/release && \
  cp -pr _build/${MIX_ENV}/rel/artemis /app/release/artemis; \
fi
