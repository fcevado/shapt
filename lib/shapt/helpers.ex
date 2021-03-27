defmodule Shapt.Helpers do
  @moduledoc false
  def do_expired(toggle, toggle_conf) do
    is_expired?(toggle_conf[toggle])
  end

  def do_all_expired(toggle_conf) do
    toggle_conf
    |> Enum.filter(&is_expired?/1)
    |> Enum.map(fn {name, _opts} -> name end)
  end

  defp is_expired?({_name, toggle_opts}), do: is_expired?(toggle_opts)

  defp is_expired?(toggle_opts) do
    Date.compare(toggle_opts[:deadline], Date.utc_today()) != :gt
  end

  def do_template(adapter, adapter_opts, toggle_conf) do
    adapter.create_template(adapter_opts, toggle_conf)
  end

  def apply_toggle(true, f, _, env) when is_function(f), do: apply(f, env)
  def apply_toggle(false, _, f, env) when is_function(f), do: apply(f, env)
  def apply_toggle(false, _, {mod, fun, env}, _), do: apply(mod, fun, env)
  def apply_toggle(true, {mod, fun, env}, _, _), do: apply(mod, fun, env)
  def apply_toggle(false, _, {mod, fun}, env), do: apply(mod, fun, env)
  def apply_toggle(true, {mod, fun}, _, env), do: apply(mod, fun, env)
  def apply_toggle(true, value, _, _), do: value
  def apply_toggle(false, _, value, _), do: value
end
