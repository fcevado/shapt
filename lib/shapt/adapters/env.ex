defmodule Shapt.Adapters.Env do
  @behaviour Shapt.Adapter
  @moduledoc """
  """

  @impl Shapt.Adapter
  def load(opts, toggles) do
    case opts[:from] do
      :file -> from_file(opts[:file], toggles)
      _from -> from_env(toggles)
    end
  end

  @impl Shapt.Adapter
  def create_template(_opts, toggles) do
    toggles
    |> Enum.map(&get_key/1)
    |> Enum.map(&"#{&1}=false")
    |> Enum.join("\n")
  end

  @impl Shapt.Adapter
  def validate_configuration(opts) do
    case opts[:from] do
      :file ->
        if File.regular?(opts[:file] || "") do
          :ok
        else
          "not a file"
        end

      _from ->
        :ok
    end
  end

  defp from_env(toggles) do
    toggles
    |> Enum.map(&env_toggle/1)
    |> Enum.into(%{})
  end

  defp env_toggle(toggle) do
    value =
      toggle
      |> get_key()
      |> System.get_env()
      |> to_boolean()

    {elem(toggle, 0), value}
  end

  defp from_file(nil, _toggles), do: %{}

  defp from_file(file, toggles) do
    keys = Enum.map(toggles, &get_key/1)
    key_toggles = Enum.map(toggles, &remap_keys/1)
    values = load_file(file, keys)

    key_toggles
    |> Enum.map(fn {k, t} -> {t, values[k] |> to_boolean()} end)
    |> Enum.into(%{})
  end

  defp load_file(file, keys) do
    case File.read(file) do
      {:error, _err} ->
        []

      {:ok, content} ->
        content
        |> String.split("\n")
        |> Enum.map(&String.split(&1, "="))
        |> Enum.map(&List.to_tuple/1)
        |> Enum.filter(&(elem(&1, 0) in keys))
        |> Enum.into(%{})
    end
  end

  defp remap_keys(toggle), do: {get_key(toggle), elem(toggle, 0)}

  defp get_key({toggle, opts}), do: opts[:key] || toggle_key(toggle)

  defp toggle_key(key) do
    key
    |> Atom.to_string()
    |> String.replace("?", "")
    |> String.upcase()
  end

  defp to_boolean("true"), do: true
  defp to_boolean(_env), do: false
end
