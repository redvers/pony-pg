# pony-pg

Pony Native Driver for Postgres

## Status

[![CircleCI](https://circleci.com/gh/redvers/pony-pg.svg?style=svg)](https://circleci.com/gh/redvers/pony-pg)

pony-pg is pre-alpha software.

## Installation

* Install [pony-stable](https://github.com/ponylang/pony-stable)
* Update your `bundle.json`

```json
{
  "type": "github",
  "repo": "redvers/pony-pg"
}
```

* `stable fetch` to fetch your dependencies
* `use "pg"` to include this package
* `stable env ponyc` to compile your application
