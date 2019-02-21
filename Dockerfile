FROM elixir:1.8.1

ARG MIX_ENV=dev

SHELL ["/bin/bash", "-c"]

WORKDIR /app
COPY . /app

RUN apt-get update && \
    apt-get install -y build-essential inotify-tools postgresql-client

RUN mix local.hex --force && \
    mix local.rebar --force

RUN curl -SL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y nodejs && \
    npm --global install yarn

RUN MIX_ENV=${MIX_ENV} bin/reset-build
