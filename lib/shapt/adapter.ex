defmodule Shapt.Adapter do
  @moduledoc """
  A behaviour that defines the basic callbacks that a Shapt Adapter needs to implement.
  This callbacks are just the very basic behavior that an adapter might have.
  """

  @typedoc """
  The name of toggle set in the Shapt config.
  """
  @type toggle_name :: atom()

  @typedoc """
  Toggle options configured at keyword list in the Shapt config.
  Common options are `key_name` and `deadline`. `deadline` is required for the mix task `Mix.Tasks.Shapt.Expired`.
  Custom Adapters can define more options.
  """
  @type toggle_opts :: map()

  @typedoc """
  Keyword list containing all toggle and toggle options config.
  """
  @type toggles :: list({toggle_name(), toggle_opts()})

  @typedoc """
  State of the GenServer created in a module that uses `Shapt`.
  `environment` - this is a way for adapters to know in which environment they are running, in case releases are being used.
  `ets` - reference of the ets table created when `ets_cache` option is set to true.
  `ets_loaded` - says if `ets` has been loaded with `load_all/1` execution.
  `toggles` - take a loot at `toggles()`
  `adapter` - Module that is configured as the adapter.
  `adapter_opts` - configuration for the `adapter`
  """
  @type state :: %{
          environment: :dev | :test | :prod,
          ets: reference(),
          ets_loaded: boolean(),
          toggles: toggles(),
          adapter: atom(),
          adapter_opts: list()
        }

  @doc """
  Verifies if a given toggle is enabled true of false.
  This only gonna be used if `ets_cache` option is set to false.
  It receives the `toggle_name()` of the key being verified and the `state()` of the Genserver.
  It include all the `state()` because adapter configuration can be used by the adapter.
  """
  @callback enabled?(toggle_name(), state()) :: boolean()

  @doc """
  Produces the template outputed by `Mix.Tasks.Shapt.Template`.
  It receives the toggles keywordlist and the adapter options and returns the binary representing the template.
  """
  @callback template(list(), map()) :: bitstring()

  @doc """
  Load all toggles current value to the ets table.
  Please make sure to enforce values are only boolean
  """
  @callback load_all(state()) :: state()

  @doc """
  Reiceves `toggle_name()` and `toggle_opts` and should return the representation of the toggle name the way the adapter understands it.
  This is used mainly because when `ets_cache` and `ets_loaded` are both set to true, the GenServer will bypass the need to use the adapter.
  Use the same value returned here to load the toggle in the `load_all/1` function.
  """
  @callback key_name(toggle_name(), toggle_opts()) :: any()
end
