defmodule Shapt.Adapter do
  @moduledoc """
  A behaviour that defines the basic callbacks that a Shapt Adapter needs to implement.
  This callbacks are just the very basic behavior that an adapter might have.
  """

  @typedoc """
  A keywordlist configuring your adapter.
  To get more details read your adapter documentation.
  """
  @type adapter_opts :: list()

  @typedoc """
  The name of toggle set in `toggles()`.
  """
  @type toggle_name :: atom()

  @typedoc """
  Toggle options set in `toggles()`.
  Adapters can define more options to be set.
  The only option enforced by Shapt is `:deadline`.
  """
  @type toggle_opts :: map()

  @typedoc """
  Deadline set in `toggle_opts()`.
  """
  @type deadline :: Date.t()

  @typedoc """
  A keywordlist containing the `toggle_name()` and `toggle_opts()`.
  """
  @type toggles :: list({toggle_name(), toggle_opts()})

  @typedoc """
  A map containing all `toggle_name()` with the value being the current state of the toggle.
  """
  @type loaded_toggles :: %{toggle_name() => boolean()}

  @doc """
  Invoked at the start of the worker and everytime a reload takes place to populate the current state of the toggles.
  It should always return a map with all `toggle_name()`.
  """
  @callback load(adapter_opts(), toggles()) :: loaded_toggles()

  @doc """
  Invoked by the task that generates the template for the adapter.
  It should return a string that can be used as a template, in case a template is not applyable for the adapter returns an empty string.
  """
  @callback create_template(adapter_opts(), toggles()) :: String.t()

  @doc """
  Invoked at the `init/1` callback of the worker.
  Returning `:ok` means the configuration is valid and the adapter will be able to load the toggle state for the given configuration.
  """
  @callback validate_configuration(adapter_opts()) :: :ok | String.t()
end
