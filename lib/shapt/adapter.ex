defmodule Shapt.Adapter do
  @moduledoc """
  A behaviour that defines the basic callbacks that a Shapt Adapter needs to implement.
  This callbacks are just the very basic behavior that an adapter might have.
  """

  @typedoc """
  A map containing all `t:Shapt.toggle_name/0` with the value being the current state of the toggle.
  """
  @type loaded_toggles :: %{Shapt.toggle_name() => boolean()}

  @doc """
  Invoked at the start of the worker and everytime a reload takes place to populate the current state of the toggles.
  It should always return a map with all `t:Shapt.toggle_name/0`.
  """
  @callback load(Shapt.adapter_opts(), Shapt.toggles()) :: loaded_toggles()

  @doc """
  Invoked by the task that generates the template for the adapter.
  It should return a string that can be used as a template, in case a template is not applyable for the adapter returns an empty string.
  """
  @callback create_template(Shapt.adapter_opts(), Shapt.toggles()) :: String.t()

  @doc """
  Invoked at the `Shapt.Worker.init/1` callback of the worker.
  Returning `:ok` means the configuration is valid and the adapter will be able to load the toggle state for the given configuration.
  """
  @callback validate_configuration(Shapt.adapter_opts()) :: :ok | String.t()
end
