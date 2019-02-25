# Atlas Platform

[![Build Status](https://travis-ci.com/chrislaskey/atlas_platform.svg?branch=master)](https://travis-ci.com/chrislaskey/atlas_platform)

## About

Atlas Platform contains enterprise ready patterns for web applications in Elixir. It can be used as:

- A starting point for a new web application
- A pattern reference for an existing web application

## Demo

A container-based demo environment is available. Assuming [docker](https://www.docker.com/) and [docker compose](https://docs.docker.com/compose/) is installed:

```bash
bin/demo/build # Build the demo environment
bin/demo/up # Start the demo environment
bin/demo/stop # Stop the demo environment
bin/demo/remove # Remove the demo environment
```

## Development

Atlas can be used as a pattern reference for an existing application or as a starting point for a new one.

To build a new application using Atlas, see the [`DEVELOPMENT.md`](DEVELOPMENT.md).
