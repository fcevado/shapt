defmodule Shapt.Adapters.Env do
  @behaviour Shapt.Adapter

  def start_link(_) do
    :ok
  end

  def enabled?(name, opts) do
    System.get_env(build_key(name, opts[:key]))
    |> to_boolean()
  end

  def template(toggles) do
    toggles
    |> Enum.map(&build_line/1)
    |> Enum.join("\n")
  end

  defp build_line({name, opts}) do
    key = build_key(name, opts[:key])

    value = opts[:force] || false

    "#{key}=#{value}"
  end

  defp build_key(name, key) do
    name_key =
      name
      |> to_string()
      |> String.replace("?", "")
      |> String.upcase()

    key || name_key
  end

  defp to_boolean("True"), do: true
  defp to_boolean("true"), do: true
  defp to_boolean(true), do: true
  defp to_boolean(_), do: false
end
