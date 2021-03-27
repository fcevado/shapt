defmodule Shapt do
  @moduledoc false
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
            Shapt.Worker.enabled?(__MODULE__, toggle)
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
            env = opts[:env]
            truthy = opts[:on]
            falsy = opts[:off]

            name
            |> enabled?()
            |> Shapt.Helpers.apply_toggle(truthy, falsy, env)
          else
            :error
          end
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
