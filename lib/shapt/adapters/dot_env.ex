defmodule Shapt.Adapters.DotEnv do
  @behaviour Shapt.Adapter

  @impl Shapt.Adapter
  def enabled?(name, state) do
    if state[:environment] in [:test, :dev] and not is_nil(state[:toggles][name][:force]) do
      state[:toggles][name][:force]
    else
      key = key_name(name, state[:toggles][name])
      file = state[:adapter_opts][:file] || Path.join(File.cwd!(), ".env")

      unless File.exists?(file), do: raise("DotEnv config file doesn't exists")

      [value] =
        file
        |> read_file()
        |> Enum.filter(fn {k, _v} -> k == key end)
        |> Enum.map(fn {_k, v} -> v end)

      value
    end
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
  def template(toggles, _opts) do
    toggles
    |> Enum.map(&build_line/1)
    |> Enum.join("\n")
  end

  @impl Shapt.Adapter
  def load_all(state) do
    ets = state[:ets]
    file = state[:adapter_opts][:file] || Path.join(File.cwd!(), ".env")
    key_names = Enum.map(state[:toggles], fn {key, opts} -> key_name(key, opts) end)

    unless File.exists?(file), do: raise("DotEnv config file doesn't exists")

    file_values =
      file
      |> read_file()
      |> Enum.filter(fn {k, _} -> k in key_names end)

    for {key_name, value} <- file_values,
        {key, opts} <- state[:toggles],
        key_name == key_name(key, opts) do
      if state[:environment] in [:dev, :test] and not is_nil(opts[:force]) do
        :ets.insert_new(ets, {key_name, opts[:force]})
      else
        :ets.insert_new(ets, {key_name, value})
      end
    end
  end

  defp read_file(file) do
    File.read!(file)
    |> String.split("\n")
    |> Enum.map(&String.split(&1, "="))
    |> Enum.map(&List.to_tuple/1)
    |> Enum.filter(&(tuple_size(&1) == 2))
    |> Enum.map(fn {k, v} -> {String.trim(k), String.trim(v) |> to_boolean()} end)
  end

  defp build_line({name, opts}) do
    key = key_name(name, opts)

    value = opts[:force] || false

    "#{key}=#{value}"
  end

  defp to_boolean("true"), do: true
  defp to_boolean(_), do: false
end
