# Artemis Platform

[![Build Status](https://travis-ci.com/chrislaskey/artemis_platform.svg?branch=master)](https://travis-ci.com/chrislaskey/artemis_platform)

## About

Artemis Platform contains enterprise ready patterns for web applications in Elixir. It can be used as:

- A starting point for a new web application
- A pattern reference for an existing web application

## Patterns

General Patterns:

- Authentication with OAuth2
- Role-Based Access Control [⬈ Documentation](https://github.com/chrislaskey/artemis_platform/wiki/Role-Based-Access-Control) [⬈ Discussion](https://github.com/chrislaskey/artemis_platform/issues/12)
- Full Text Search [⬈ Documentation](https://github.com/chrislaskey/artemis_platform/wiki/Full-Text-Search) [⬈ Discussion](https://github.com/chrislaskey/artemis_platform/issues/13)
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
- Table Export
- Table Sorting
- Table Filtering

Planned:

- Node Clustering
- On-demand Caching

## Demo

A container-based demo environment is available. Assuming [docker](https://www.docker.com/) and [docker compose](https://docs.docker.com/compose/) is installed:

```bash
bin/demo/build # Build the demo environment
bin/demo/up # Start the demo environment
bin/demo/stop # Stop the demo environment
bin/demo/remove # Remove the demo environment
```

## Development

Artemis can be used as a pattern reference for an existing application or as a starting point for a new one.

To build a new application using Artemis, see the [`DEVELOPMENT.md`](DEVELOPMENT.md).

## Looking for More?

> ### [Artemis Dashboard](https://github.com/chrislaskey/artemis_dashboard)

Artemis Dashboard is an example of a complete application (including UI and design) built on top of Artemis Platform.

> ### [Artemis Teams](https://github.com/chrislaskey/artemis_teams)

Collaborative Team-Based Tools written in Elixir and Phoenix.
