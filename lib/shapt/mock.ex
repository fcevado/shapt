defmodule Shapt.Mock do
  @moduledoc """
  A behaviour that would allow you to mock your toggles with `Mox` and an actual default implementation of the behaviour.
  The default implementation is done so you don't need add `Mox` to your dependencies if you need basic tests abilities.
  If you already have `Mox` as a dependency, it's strongly recommended to use `Mox` instead of the default implementation.

  The default implementation uses process dictionary to store the state of the toggles.
  If you're using `Shapt.Mock`, you should always sanitize the process dictionary with `Shapt.Mock.cleanup/0` at the end of your tests.

  To setup your mock you need to set it on your config file:
  ```
  config :shapt, MyApp.Toggle,
    mock: MyApp.ToggleTest
  ```
  """

  @doc """
  Invoked by modules that uses `Shapt` to evalute if the toggle is enabled.
  """
  @callback enabled?(module(), Shapt.toogle_name()) :: boolean()

  @doc """
  Set the state for the toggles of a Shapt module.
  
  ```
  iex> Shapt.Mock.set(MyApp.Toggle, %{feature_x: true})
  :ok

  iex> Shapt.Mock.set(MyApp.Toggle, [feature_x: true])
  :error
  ```
  """
  @spec set(module(), map()) :: :ok | :error
  def set(module, flippers) when is_atom(module) and is_map(flippers) do
    case Process.get(__MODULE__) do
      nil -> Process.put(__MODULE__, %{module => flippers})
      state -> Process.put(__MODULE__, Map.put(state, module, flippers))
    end

    :ok
  end
  def set(_, _), do: :error

  @doc """
  Default implementation of the `Shapt.Mock` behaviour using process dictionary to evaluate the state of a toggle.

  ```
  iex> Shapt.Mock.enabled?(Test, :feature_x)
  false
  ```
  """
  @spec enabled?(module(), Shapt.toogle_name()) :: boolean()
  def enabled?(module, toggle) do  
    case Process.get(__MODULE__)[module][toggle] |> IO.inspect(label: "#{module}:#{toggle}:") do
      nil -> false
      value -> value
    end
  end

  @doc """
  Cleans up the state of the process after running a test.

  ```
  iex> Shapt.Mock.cleanup()
  :ok
  ```
  """
  @spec cleanup() :: :ok
  def cleanup do
    Process.put(__MODULE__, nil)

    :ok
  end
end
