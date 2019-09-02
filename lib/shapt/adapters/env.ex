defmodule Shapt.Adapters.Env do
  @behaviour Shapt.Adapter

  @impl Shapt.Adapter
  def enabled?(name, state) do
    if state[:environment] in [:test, :dev] and not is_nil(state[:toggles][name][:force]) do
      state[:toggles][name][:force]
    else
      System.get_env(key_name(name, state[:toggles][name]))
      |> to_boolean()
    end
  end

  @impl Shapt.Adapter
  def template(toggles, _opts) do
    toggles
    |> Enum.map(&build_line/1)
    |> Enum.join("\n")
  end

  @impl Shapt.Adapter
  def key_name(name, opts) do
    name_key =
      name
      |> to_string()
      |> String.replace("?", "")
      |> String.upcase()

    opts[:key] || name_key
  end

  @impl Shapt.Adapter
  def load_all(state) do
    ets = state[:ets]

    state[:toggles]
    |> Enum.map(&read_key(&1, state[:environment]))
    |> Enum.each(&:ets.insert_new(ets, &1))
  end

  defp read_key({key, opts}, env) do
    value =
      if env in [:test, :dev] and not is_nil(opts[:force]) do
        opts[:force]
      else
        System.get_env(key_name(key, opts))
        |> to_boolean()
      end

    {key_name(key, opts), value}
  end

  defp build_line({name, opts}) do
    key = key_name(name, opts[:key])

    value = opts[:force] || false

    "#{key}=#{value}"
  end

  defp to_boolean("True"), do: true
  defp to_boolean("true"), do: true
  defp to_boolean(true), do: true
  defp to_boolean(_), do: false
end
