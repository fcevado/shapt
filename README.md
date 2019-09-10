# Shapt
A helpful and simple way to use feature toggles/flippers/flags on your Elixir code.
This library heavily uses macros to achieve it's goals. Please read our [usage guide](./USAGE.md).

This is library is currently a work in progress, it's api is not *strongly* defined, *expect changes*.

## [Name](./NAME.md)
Do what you want 'cause a pirate is free
You are a pirate!

Yar har, fiddle de dee
Being a pirate is alright to be
Do what you want 'cause a pirate is free
You are a pirate!

## Features
This are the list of main features(marked ones are already implemented):
* [x] Configurable adapters that are simple to implement.
* [x] `Shapt.Adapters.Env` and `Shapt.Adapters.DotEnv` built-in Adapters.
* [x] `shapt.expired` mix task that exposes toggles that had his deadline expired.
* [x] `shapt.template` mix task that generate template files for the configured adapter.
* [x] Plug that provides a `GET` endpoint to inspect current state of the toggles.
* [x] Plug that provides a `POST` endpoint that reload toggles value(reload feature must be provided by the Adapter).
* [ ] Consul Adapters

## [Usage Guide](./USAGE.md)
Read our usage guide to understand how to start using this library.

## Credits
This library is inspired by several ideas from [Renan Ranelli](https://github.com/rranelli).

## [Changelog](./CHANGELOG.md)
* current version v0.0.1

## [Code of Conduct](./CODE_OF_CONDUCT.md)

## License
Shapt is under Apache v2.0 license. Check the [LICENSE](./LICENSE.md) file for more details.
