# Development with Atlas

Atlas can be used to jump-start a new web application.

## Common Setup

Atlas supports both local and containerized development. Regardless of which is used, the following common setup steps should be followed.

### Code Repository

Fork the code repository and pull down the latest with `git clone <PATH_TO_FORKED_REPOSITORY>`.

Create a custom `.env` file:

```bash
cp .env.example .env
```

Review the environment file and follow commented documentation to populate the required values:

```bash
vim .env
```

### System Ports and Local DNS

Atlas runs a development webserver on a local port. The default port is specified in the `.env` file, but can be changed.

For websocket support, Atlas must be reachable through local DNS at `https://atlas.dev`. A local DNS manager with SSL support like [Puma Dev](https://github.com/puma/puma-dev) makes this easy.

If using Puma Dev, this can be accomplished by creating a new puma dev config file:

```
source .env
echo $ATLAS_PORT > ~/.puma-dev/atlas
```

## Docker Environment

A container-based development environment is available using [docker](https://www.docker.com/) and [docker compose](https://docs.docker.com/compose/). Once the docker platform is installed, build and run the containers:

```bash
bin/docker/build
bin/docker/up
```

## Local Environment

### Elixir

Atlas requires a specific version of Elixir. The version is always specified in `.env.example`.

An Elixir version manager like [`kiex`](https://github.com/taylor/kiex) can make it easy to manage multiple Elixir versions in the same development environment.

### Node

Atlas requires a specific version of NodeJS. The version is always specified in `.env.example`.

A Node version manager like [`nvm`](https://github.com/creationix/nvm) can make it easy to manage multiple Node versions in the same development environment.

### PostgreSQL

Atlas requires PostgreSQL >= 9.6.

For an example of running it through a Docker image see the [Bluebox Box](https://github.ibm.com/bluebox/box) repository.

Alternatively, it can be installed locally on the command-line using `brew install postgresql` or with a standalone application like [Postico](https://eggerapps.at/postico/).

### Browser Testing

Atlas requires headless chrome for browser-based testing.

It can be installed locally on the command-line using `brew cask install chromedriver`.

### Initial Configuration

Before running the application the first time, execute `bin/reset-all`.

**Warning**: The `bin/reset-all` script is destructive. It will drop current dependencies and pull down the latest, and it will drop databases and recreate them with seed data.

## Testing

### Docker

If not running already, start an instance of the development environment:

```bash
bin/docker/up
```

Then execute the tests using:

```bash
bin/docker/test
```

### Local Development

#### Unit Tests

Comprehensive unit tests are included in Atlas. To run them use:

```bash
bin/local/test
```

#### Browser Tests

Before running browser tests, start the headless chrome server with `chromedriver --headless`.

By default, browser tests are **only** run in the CI environment. To run them use:

```bash
mix test --include browser # runs all tests including browser tests
mix test --only browser # runs only browser tests
```
