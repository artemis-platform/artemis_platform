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
echo $atlas_PORT > ~/.puma-dev/atlas
```

#### Initial Configuration

Before running the application the first time, execute `bin/reset-all`.

**Warning**: The `bin/reset-all` script is destructive. It will drop current dependencies and pull down the latest, and it will drop databases and recreate them with seed data.

## Initial Application Setup

Setup new umbrella project:

```
mix phx.new atlas --umbrella --app atlas
```

#### SASS Support

Add the `sass` packages:

```
npm install --save-dev node-sass sass-loader
```

Update the webpack config:

```
{
  test: /\.scss$/,
  use: [MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader']
}
```

#### Vendor Packages

Download the latest [Semantic UI CSS](https://github.com/Semantic-Org/Semantic-UI-CSS) package and [Select2](https://www.npmjs.com/package/select2) dependencies locally:

```
cd apps/atlas/assets
npm install jquery
npm install select2
npm install semantic-ui-css
```

Copy the theme assets into `static`:

```
cp ./node_modules/semantic-ui-css/themes/default/assets/fonts/* ./static/fonts/
cp ./node_modules/semantic-ui-css/themes/default/assets/images/* ./static/images/
```

Copy the CSS and JS files into `vendor`:

```
cp ./node_modules/jquery/dist/jquery.min.js ./vendor/01-jquery.min.js
cp ./node_modules/select2/dist/css/select2.css ./vendor/02-select2-v4.0.6.css
cp ./node_modules/select2/dist/js/select2.min.js ./vendor/02-select2-v4.0.6.min.js
cp ./node_modules/semantic-ui-less/semantic.css ./vendor/03-semantic-ui-v2.4.1.css
cp ./node_modules/semantic-ui-less/semantic.min.js ./vendor/03-semantic-ui-v2.4.1.min.js
```

**Note**: The `01-` naming convention ensures the proper load order of vendored files.

Update CSS references to point to files in `static` directory:

```
vim vendor/03-semantic-ui-v2.4.1.css
<esc>:%s#./themes/default/assets##
```

Add the CSS files to `assets/css/app.scss`:

```
@import "../vendor/02-select2-v4.0.6.css";
@import "../vendor/03-semantic-ui-v2.4.1.css";
```

#### Browser Polyfills and Vendor Package Initializers

Polyfills for browser support can be added to `assets/vendor/00-polyfills.js`.

Vendor packages that require initializers can be added to `assets/vendor/99-initializers.js`.
