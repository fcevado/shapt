defmodule Shapt.Adapter do
  @moduledoc """
  A behaviour that defines the basic callbacks that a Shapt Adapter needs to implement.
  This callbacks are just the very basic behavior that an adapter might have.
  """
  @doc """
  Verifies if a given toggle is enabled true of false.
  It receives the `name` of the toggle and the `options` set when you configure it.
  The available options are defined by the Adapter, the only exception is the `deadline` option.
  """
  @callback enabled?(atom(), map()) :: boolean()

  @doc """
  Produces the template outputed by `Mix.Tasks.Shapt.Template`.
  It receives the toggles keywordlist and returns the binary representing the template.
  """
  @callback template(list()) :: bitstring()
end
