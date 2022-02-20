defmodule Shapt do
  @moduledoc """
  Use this to create your own feature toggle worker as in the example:

  ```elixir
  defmodule TestModule do
    use Shapt,
      adapter: {Shapt.Adapters.Env, []},
      toggles: [
        feature_x?: %{
          key: "MYAPP_FEATURE_X",
          deadline: ~D[2019-12-31]
          },
        feature_y?: %{
          deadline: ~D[2009-12-31]
          }
        ]
  end
  ```
  """

  @typedoc """
  Options to be passed when using `Shapt`.
  It's a keywordlist with the required keys `:adapter` and `:toggles`.
  """
  @type use_opts :: [adapter: {adapter(), adapter_opts()}, toggles: toggles()]

  @typedoc """
  A module that implements the `Shapt.Adapter` behaviour.
  """
  @type adapter :: module()

  @typedoc """
  Options to configure the adapter.
  Check the adapter documentation for more details.
  """
  @type adapter_opts :: keyword()

  @typedoc """
  A keywordlist with the toggles names and its configuration.
  """
  @type toggles :: [{toggle_name(), toggle_opts()}]

  @typedoc """
  The name of a toggle.
  This name gonna become a function on your module and gonna be name used to identify this toggle on all Shapt mix tasks.
  """
  @type toggle_name :: atom()

  @typedoc """
  It's a map with options to configure the individual toggle.
  The only option that Shapt defines is the `:deadline`.
  More options can be defined and used by the adapter.
  """
  @type toggle_opts :: %{deadline: deadline()}

  @typedoc """
  Defines a deadline for using the toggle.
  It's used by `Mix.Tasks.Shapt.Expired` task and the functions `expired?/1` and `expired_toggles/0`.
  """
  @type deadline :: Date.t()

  @doc false
  defmacro __using__(options) do
    {adapter, adapter_conf} = options[:adapter]
    toggle_conf = options[:toggles]
    toggles = Enum.map(toggle_conf, &elem(&1, 0))

    [
      quote do
        
        def child_spec([]) do
          opts = [
            toggles: unquote(toggle_conf),
            adapter: {unquote(adapter), unquote(adapter_conf)},
            module: __MODULE__
          ]

          Shapt.Worker.child_spec(opts)
        end

        def child_spec(params) do
          opts = [
            toggles: unquote(toggle_conf),
            adapter: params[:adapter],
            module: __MODULE__
          ]

          Shapt.Worker.child_spec(opts)
        end

        def start_link([]) do
          opts = [
            toggle_conf: unquote(toggle_conf),
            adapter: unquote(adapter),
            adapter_conf: unquote(adapter_conf),
            name: __MODULE__
          ]

          Shapt.Worker.start_link(opts)
        end

        def start_link(params) do
          {adapter, adapter_conf} = params[:adapter]

          opts = [
            toggle_conf: unquote(toggle_conf),
            adapter: adapter,
            adapter_conf: adapter_conf,
            name: __MODULE__
          ]

          Shapt.Worker.start_link(opts)
        end

        def all_values, do: Shapt.Worker.all_values(__MODULE__)

        def reload, do: Shapt.Worker.reload(__MODULE__)

        def enabled?(toggle) do
          if toggle in unquote(toggles) do
            adapter().enabled?(__MODULE__, toggle)
          else
            :error
          end
        end

        def expired?(toggle) do
          Shapt.Helpers.do_expired(toggle, unquote(toggle_conf))
        end

        def expired_toggles do
          Shapt.Helpers.do_all_expired(unquote(toggle_conf))
        end

        def template do
          Shapt.Helpers.do_template(unquote(adapter), unquote(adapter_conf), unquote(toggle_conf))
        end

        def toggle(name, opts) do
          if name in unquote(toggles) do
            name
            |> enabled?()
            |> Shapt.Helpers.apply_toggle(opts)
          else
            :error
          end
        end

        defp adapter do
          Application.get_env(:shapt, __MODULE__)[:mock] || Shapt.Worker
        end
      end
      | Enum.map(options[:toggles], fn {name, _opts} ->
          quote do
            def unquote(name)(), do: enabled?(unquote(name))
          end
        end)
    ]
  end
end
