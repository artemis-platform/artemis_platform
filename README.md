# Artemis Platform

[![Build Status](https://travis-ci.com/artemis-platform/artemis_platform.svg?branch=master)](https://travis-ci.com/artemis-platform/artemis_platform)

## About

Artemis Platform contains enterprise ready patterns for web applications in Elixir. It can be used as:

- A starting point for a new web application
- A pattern reference for an existing web application

View a live demo at [https://artemis-platform.com/](https://artemis-platform.com/).

## Patterns

General Patterns:

- Authentication with OAuth2
- Role-Based Access Control [⬈ Documentation](https://github.com/artemis-platform/artemis_platform/wiki/Role-Based-Access-Control) [⬈ Discussion](https://github.com/artemis-platform/artemis_platform/issues/12)
- Full Text Search [⬈ Documentation](https://github.com/artemis-platform/artemis_platform/wiki/Full-Text-Search) [⬈ Discussion](https://github.com/artemis-platform/artemis_platform/issues/13)
- Event Based Pub/Sub
- Dedicated Audit Logging
- Dynamic Caching
- Feature Flipper
- GraphQL API Endpoint
- Phoenix Web Endpoint
- Docker Support
- Unit Testing
- Browser-based Testing

UI Patterns:

- Breadcrumbs
- Pagination
- Table Search
- Table Export
- Table Sorting
- Table Filtering

## Demo

View a live demo at [https://artemis-platform.com/](https://artemis-platform.com/).

Or spin up a demo locally. Assuming [docker](https://www.docker.com/) and [docker compose](https://docs.docker.com/compose/) is installed:

```bash
bin/demo/build # Build the demo environment
bin/demo/up # Start the demo environment
bin/demo/stop # Stop the demo environment
bin/demo/remove # Remove the demo environment
```

Once built and started, the demo environment is available at: http://localhost:4077

## Development

Artemis can be used as a pattern reference for an existing application or as a starting point for a new one.

To build a new application using Artemis, see the [`DEVELOPMENT.md`](DEVELOPMENT.md).

## Looking for More?

> ### [Artemis Dashboard](https://github.com/artemis-platform/artemis_dashboard)

Artemis Dashboard is an example of a complete application (including UI and design) built on top of Artemis Platform.
