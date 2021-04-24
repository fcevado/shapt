# Changelog

## v0.1.0

- Restructure internals of the library
- Simplify Shapt.Adapters.Env
- Remove Shapt.Adapters.DotEnv in favor of using Shapt.Adapters.Env with optional config.
- Always use ets table as state holder for the toggle values.

## v0.0.4

- Pretty print map on GET endpoint.
- Fix issue with mix tasks

## v0.0.3

- Fix issue with mix tasks

## v0.0.2

- Make the toggle module a worker that needs to be attached to a supervision
  tree or started with `start_link`.
- Refactor Adapters to work with worker architeture.
- Add option to have ets cache for all adapters.
- Add instance_name function to be used on Consul adapters.
- Add reload and all_values functions and callbacks
- Add plug

## v0.0.1

- Initial Release
