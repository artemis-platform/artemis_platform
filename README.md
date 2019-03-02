# Atlas Platform

[![Build Status](https://travis-ci.com/chrislaskey/atlas_platform.svg?branch=master)](https://travis-ci.com/chrislaskey/atlas_platform)

## About

Atlas Platform contains enterprise ready patterns for web applications in Elixir. It can be used as:

- A starting point for a new web application
- A pattern reference for an existing web application

## Patterns

General Patterns:

- Authentication with OAuth2
- Role-Based Access Control
- Full Text Search
- Event Based Pub/Sub
- Dedicated Audit Logging
- Feature Flipper
- GraphQL API Endpoint
- Phoenix Web Endpoint
- Docker Support
- Unit Testing
- Browser-based Feature Testing

UI Patterns:

- Breadcrumbs
- Pagination
- Table Search

In Flight:

- Optional RabbitMQ Support
- On-demand Caching

Planned:

- Node Clustering
- Table Sorting
- Table Filtering
- Table Export

## Demo

A container-based demo environment is available. Assuming [docker](https://www.docker.com/) and [docker compose](https://docs.docker.com/compose/) is installed:

```bash
bin/demo/build # Build the demo environment
bin/demo/up # Start the demo environment
bin/demo/stop # Stop the demo environment
bin/demo/remove # Remove the demo environment
```

## Looking for a UI Design?

> ### [Atlas Dashboard](https://github.com/chrislaskey/atlas_dashboard)

Atlas Dashboard is an example of a complete application (including UI and design) built on top of Atlas Platform.

## Development

Atlas can be used as a pattern reference for an existing application or as a starting point for a new one.

To build a new application using Atlas, see the [`DEVELOPMENT.md`](DEVELOPMENT.md).
