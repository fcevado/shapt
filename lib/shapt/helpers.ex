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

  def apply_toggle(true, opts), do: apply_toggle(opts[:on])
  def apply_toggle(false, opts), do: apply_toggle(opts[:off])

  defp apply_toggle({f, args}) when is_function(f), do: apply(f, args)
  defp apply_toggle({m, f, args}), do: apply(m, f, args)
  defp apply_toggle(term), do: term
end
