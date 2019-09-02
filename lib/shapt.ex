defmodule Shapt do
  @moduledoc false
  defmacro __using__(options) do
    [
      quote do
        use GenServer
        defdelegate init(opts), to: Shapt
        defdelegate handle_call(msg, from, state), to: Shapt
        defdelegate apply_toggle(value, truthy, falsy, env), to: Shapt

        def child_spec(params) do
          %{
            id: __MODULE__,
            start: {__MODULE__, :start_link, [params]},
            restart: :permanent,
            shutdown: 5000,
            type: :worker
          }
        end

        def start_link(opts) do
          opts = Keyword.drop(opts, [:name])
          GenServer.start_link(__MODULE__, unquote(options), [name: __MODULE__] ++ opts)
        end

        def enabled?(toggle) do
          GenServer.call(__MODULE__, {:enabled, toggle})
        end

        def expired?(toggle) do
          GenServer.call(__MODULE__, {:expired, toggle})
        end

        def expired_toggles do
          GenServer.call(__MODULE__, {:expired, :all})
        end

        def template do
          GenServer.call(__MODULE__, :template)
        end

        def toggle(name, opts) do
          env = opts[:env]
          truthy = opts[:on]
          falsy = opts[:off]

          name
          |> enabled?()
          |> apply_toggle(truthy, falsy, env)
        end

        def instance_name, do: nil

        defoverridable instance_name: 0
      end
      | Enum.map(options[:toggles], fn {name, _opts} ->
          quote do
            def unquote(name)(), do: enabled?(unquote(name))
          end
        end)
    ]
  end

  @environment Mix.env()

  def init(opts) do
    {adapter, adapter_opts} = get_adapter(opts)

    state = %{
      ets: create_table(opts),
      ets_loaded: false,
      environment: @environment,
      toggles: opts[:toggles],
      adapter: adapter,
      adapter_opts: adapter_opts
    }

    {:ok, state}
  end

  def handle_call({:enabled, toggle}, _from, state) do
    state = load(state)

    value =
      if state[:ets] do
        key_name = state[:adapter].key_name(toggle, state[:toggles][toggle])
        [{^key_name, value}] = :ets.lookup(state[:ets], key_name)
        value
      else
        state[:adapter].enabled?(toggle, state)
      end

    {:reply, value, state}
  end

  def handle_call({:expired, :all}, _from, state) do
    expired =
      state[:toggles]
      |> Enum.filter(&is_expired?/1)
      |> Enum.map(fn {name, _opts} -> name end)

    {:reply, expired, state}
  end

  def handle_call({:expired, name}, _from, state) do
    {:reply, is_expired?({name, state[:toggles][name]}), state}
  end

  def handle_call(:template, _from, state) do
    template = state[:adapter].template(state[:toggles], state[:adapter_opts])

    {:reply, template, state}
  end

  def apply_toggle(false, _, tuple, _) when is_tuple(tuple),
    do: apply(elem(tuple, 0), elem(tuple, 1), elem(tuple, 2))

  def apply_toggle(true, function, _, env) when is_function(function),
    do: apply(function, env)

  def apply_toggle(false, _, function, env) when is_function(function),
    do: apply(function, env)

  def apply_toggle(true, value, _, _), do: value
  def apply_toggle(false, _, value, _), do: value

  defp get_adapter(opts) do
    case Mix.env() do
      :prod ->
        opts[:adapter][:prod] || {Shapt.Adapters.Env, []}

      :dev ->
        opts[:adapter][:dev] || {Shapt.Adapters.DotEnv, []}

      :test ->
        opts[:adapter][:test] || opts[:adapter][:dev] || {Shapt.Adapters.DotEnv, []}
    end
  end

  defp create_table(opts) do
    if opts[:ets_cache] do
      :ets.new(:shapt, [:set, :private])
    else
      nil
    end
  end

  defp load(%{ets: nil} = state), do: state
  defp load(%{ets_loaded: true} = state), do: state

  defp load(state) do
    state[:adapter].load_all(state)
    %{state | ets_loaded: true}
  end

  defp is_expired?({_name, opts}) do
    Date.compare(opts[:deadline], Date.utc_today()) != :gt
  end
end
