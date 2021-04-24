defmodule Shapt.Worker do
  @moduledoc false

  use GenServer

  @spec child_spec(keyword()) :: map()
  def child_spec(conf) do
    module = conf[:module]
    {adapter, adapter_conf} = conf[:adapter]

    opts = [
      toggle_conf: conf[:toggles],
      adapter: adapter,
      adapter_conf: adapter_conf,
      name: module
    ]

    %{
      id: module,
      start: {__MODULE__, :start_link, [opts]},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  @spec start_link(keyword()) :: {:ok, pid()} | {:error, term()}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  @spec all_values(term()) :: map()
  def all_values(worker) do
    GenServer.call(worker, :all_values)
  end

  @spec enabled?(term(), atom()) :: boolean()
  def enabled?(worker, toggle) do
    GenServer.call(worker, {:enabled, toggle})
  end

  @spec reload(term()) :: :ok
  def reload(worker) do
    GenServer.call(worker, :reload)
  end

  @impl GenServer
  def init(opts) do
    with :ok <- adapter?(opts[:adapter]),
         :ok <- opts[:adapter].validate_configuration(opts[:adapter_conf]) do
      {:ok, nil, {:continue, opts}}
    else
      error ->
        {:error, {opts[:adapter], error}}
    end
  end

  @impl GenServer
  def handle_continue(opts, nil) do
    table = :ets.new(:shapt, [:set, :private])
    adapter = opts[:adapter]
    adapter_conf = opts[:adapter_conf]
    toggles_conf = opts[:toggle_conf]
    toggles = Enum.map(toggles_conf, &elem(&1, 0))

    state = %{
      table: table,
      adapter: adapter,
      adapter_conf: adapter_conf,
      toggles_conf: toggles_conf,
      toggles: toggles
    }

    do_reload(state)

    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:all_values, _from, state) do
    response =
      state[:table]
      |> :ets.tab2list()
      |> Enum.into(%{})

    {:reply, response, state}
  end

  @impl GenServer
  def handle_call({:enabled, toggle}, _from, state) do
    response =
      with true <- toggle in state[:toggles],
           [{_toggle, value}] <- :ets.lookup(state[:table], toggle) do
        value
      else
        _any -> nil
      end

    {:reply, response, state}
  end

  @impl GenServer
  def handle_call(:reload, _from, state) do
    do_reload(state)
    {:reply, :ok, state}
  end

  defp do_reload(state) do
    state[:adapter_conf]
    |> state[:adapter].load(state[:toggles_conf])
    |> Enum.each(&:ets.insert(state[:table], &1))
  end

  defp adapter?(adapter) do
    if Code.ensure_loaded?(adapter) and Shapt.Adapter in adapter.__info__(:attributes)[:behaviour] do
      :ok
    else
      "not an adapter"
    end
  end
end
