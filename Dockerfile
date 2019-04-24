FROM elixir:1.8.1

ARG MIX_ENV=prod

ENV MIX_ENV=${MIX_ENV}

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y apt-utils build-essential inotify-tools postgresql-client

RUN curl -SL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y nodejs && \
    npm --global install yarn

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new 1.4.1

WORKDIR /app
COPY . /app

RUN MIX_ENV=${MIX_ENV} bin/local/reset-build && \
    MIX_ENV=${MIX_ENV} bin/local/reset-assets

RUN if [ "${MIX_ENV}" = "prod" ]; then \
  cp .env /.env && \
  source .env && \
  MIX_ENV=${MIX_ENV} mix release --verbose && \
  mkdir /release && \
  cp _build/${MIX_ENV}/rel/artemis/releases/*/artemis.tar.gz /release && \
  cd /release && \
  tar -xzf artemis.tar.gz && \
  rm artemis.tar.gz; \
fi
