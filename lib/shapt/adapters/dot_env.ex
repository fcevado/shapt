defmodule Shapt.Adapters.DotEnv do
  use GenServer
  @behaviour Shapt.Adapter

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    file = opts[:file] || Path.join(File.cwd!(), ".env")

    if File.exists?(file) do
      {:ok, nil, {:continue, opts}}
    else
      {:error, {:file_doesnt_exist, file}}
    end
  end

  def handle_continue(opts, nil) do
    file = opts[:file] || Path.join(File.cwd!(), ".env")
    ets = prepare_ets(file)

    {:noreply, ets}
  end

  def handle_call({:get, key}, _from, ets) do
    [{^key, value}] = :ets.lookup(ets, key)
    {:reply, value, ets}
  end

  def enabled?(name, opts) do
    GenServer.call(__MODULE__, {:get, build_key(name, opts[:key])})
  end

  def template(toggles) do
    toggles
    |> Enum.map(&build_line/1)
    |> Enum.join("\n")
  end

  defp prepare_ets(file) do
    ets = :ets.new(:dotenv, [:set, :private])

    File.read!(file)
    |> String.split("\n")
    |> Enum.map(&String.split(&1, "="))
    |> Enum.map(&List.to_tuple/1)
    |> Enum.filter(&(tuple_size(&1) == 2))
    |> Enum.map(fn {k, v} -> {String.trim(k), String.trim(v) |> to_boolean()} end)
    |> Enum.each(&:ets.insert_new(ets, &1))

    ets
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

  defp to_boolean("true"), do: true
  defp to_boolean(_), do: false
end
