defmodule Shapt do
  @moduledoc false
  defmacro __using__(options) do
    toggles = options[:toggles]

    {adapter, adapter_opts} =
      case Mix.env() do
        :prod ->
          options[:adapter][:prod] || {Shapt.Adapters.Env, []}

        :dev ->
          options[:adapter][:dev] || {Shapt.Adapters.DotEnv, []}

        :test ->
          options[:adapter][:test] || options[:adapter][:dev] || {Shapt.Adapters.DotEnv, []}
      end

    [
      quote do
        import Shapt

        defp adapter, do: unquote(adapter)
        defp toggles, do: unquote(toggles)

        def start_link() do
          adapter().start_link(unquote(adapter_opts))
        end

        defp toggle_opts(name) do
          toggles()[name]
        end

        def enabled?(name) do
          adapter().enabled?(name, toggle_opts(name))
        end

        def expired?(name) do
          Date.compare(toggle_opts(name)[:deadline], Date.utc_today()) != :gt
        end

        def expired_toggles do
          toggles()
          |> Enum.map(fn {name, _opts} -> name end)
          |> Enum.filter(&expired?/1)
        end

        def output_template do
          adapter().template(toggles())
        end

        def toggle(name, opts) do
          env = opts[:env]
          truthy = opts[:on]
          falsy = opts[:off]

          name
          |> enabled?()
          |> apply_toggle(truthy, falsy, env)
        end

        defp apply_toggle(true, tuple, _, _) when is_tuple(tuple),
          do: apply(elem(tuple, 0), elem(tuple, 1), elem(tuple, 2))

        defp apply_toggle(false, _, tuple, _) when is_tuple(tuple),
          do: apply(elem(tuple, 0), elem(tuple, 1), elem(tuple, 2))

        defp apply_toggle(true, function, _, env) when is_function(function),
          do: apply(function, env)

        defp apply_toggle(false, _, function, env) when is_function(function),
          do: apply(function, env)

        defp apply_toggle(true, value, _, _), do: value
        defp apply_toggle(false, _, value, _), do: value
      end
      | Enum.map(toggles, fn {name, _opts} ->
          quote do
            def unquote(name)(), do: enabled?(unquote(name))
          end
        end)
    ]
  end
end
