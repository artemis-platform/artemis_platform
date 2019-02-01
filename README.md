# Atlas

## Developer Environment Setup

#### Elixir

Atlas requires a specific version of Elixir. The version is always specified in `.env.example`.

An Elixir version manager like [`kiex`](https://github.com/taylor/kiex) can make it easy to manage multiple Elixir versions in the same development environment.

#### Node

Atlas requires a specific version of NodeJS. The version is always specified in `.env.example`.

A Node version manager like [`nvm`](https://github.com/creationix/nvm) can make it easy to manage multiple Node versions in the same development environment.

#### PostgreSQL

Atlas requires PostgreSQL 10.X.

For an example of running it through a Docker image see the [Bluebox Box](https://github.ibm.com/bluebox/box) repository.

Alternatively, it can be installed locally on the command-line using `brew install postgresql` or with a standalone application like [Postico](https://eggerapps.at/postico/).

#### Code Repository

Fork the [code repository](https://github.ibm.com/bluebox/atlas) and pull down the latest with `git clone PATH_TO_FORKED_REPOSITORY`.

Create a custom `.env` file:

```
cp .env.example .env
vim .env
```

#### System Ports and Local DNS

Atlas runs a development webserver on a local port. The default port is specified in the `.env` file, but can be changed.

For websocket support, Atlas must be reachable through local DNS at `https://atlas.dev`. A local DNS manager with SSL support like [Puma Dev](https://github.com/puma/puma-dev) makes this easy.

If using Puma Dev, this can be accomplished by creating a new puma dev config file:

```
source .env
echo $ATLAS_PORT > ~/.puma-dev/atlas
```

#### Initial Configuration

Before running the application the first time, execute `bin/reset-all`.

**Warning**: The `bin/reset-all` script is destructive. It will drop current dependencies and pull down the latest, and it will drop databases and recreate them with seed data.
