FROM elixir:1.8.1

ARG MIX_ENV=dev

SHELL ["/bin/bash", "-c"]

WORKDIR /app
COPY . /app

RUN apt-get update && \
    apt-get install -y apt-utils build-essential inotify-tools postgresql-client

RUN curl -SL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y nodejs && \
    npm --global install yarn

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new 1.4.1

RUN MIX_ENV=${MIX_ENV} bin/local/reset-build && \
    MIX_ENV=${MIX_ENV} bin/local/reset-assets
