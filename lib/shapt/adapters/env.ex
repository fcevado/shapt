defmodule Shapt.Adapters.Env do
  @behaviour Shapt.Adapter
  @moduledoc """
  An adapter to load toggle state from environment variables or an env file.
  """

  @typedoc """
  Additional option to configure the toggle.
  #{__MODULE__} only defines one additional option that is `:key`.
  The key is the name of the environment variable to get the toggle state.

  If there is no `:key` set for a toggle, the adapter gonna abstract an environment variable from the `Shapt.toggle_name()`.
  The environment variable for that case gonna be the `t:Shapt.toggle_name/0` upcased and stripped from a question mark, if there is any.
  """
  @type toggle_opts :: %{key: String.t()}

  @typedoc """
  Configuration for this adapter.
  - `from`: source of the state of the toggles.
    The only options are `:file` and `:env`.
    If the `from` is set to `:file`, the option `file` is required.

  - `file`: Required when `from` is set to `:file`.
    It gonna be envinroment variable file used to load the toggles state.
  """
  @type adapter_opts :: [from: :file | :env, file: filename()]

  @typedoc """
  Path to a file that must exist when starting the Shapt worker.
  The content of the file must be a pair `ENVVAR=true` per line.
  This gonna be loaded and used as the state of the toggles.
  """
  @type filename :: Path.t()

  @impl Shapt.Adapter
  def load(opts, toggles) do
    case opts[:from] do
      :file -> from_file(opts[:file], toggles)
      _from -> from_env(toggles)
    end
  end

  @impl Shapt.Adapter
  def create_template(_opts, toggles) do
    toggles
    |> Enum.map(&get_key/1)
    |> Enum.map(&"#{&1}=false")
    |> Enum.join("\n")
  end

  @impl Shapt.Adapter
  def validate_configuration(opts) do
    case opts[:from] do
      :file ->
        if File.regular?(opts[:file] || "") do
          :ok
        else
          "not a file"
        end

      _from ->
        :ok
    end
  end

  defp from_env(toggles) do
    toggles
    |> Enum.map(&env_toggle/1)
    |> Enum.into(%{})
  end

  defp env_toggle(toggle) do
    value =
      toggle
      |> get_key()
      |> System.get_env()
      |> to_boolean()

    {elem(toggle, 0), value}
  end

  defp from_file(nil, _toggles), do: %{}

  defp from_file(file, toggles) do
    keys = Enum.map(toggles, &get_key/1)
    key_toggles = Enum.map(toggles, &remap_keys/1)
    values = load_file(file, keys)

    key_toggles
    |> Enum.map(fn {k, t} -> {t, values[k] |> to_boolean()} end)
    |> Enum.into(%{})
  end

  defp load_file(file, keys) do
    case File.read(file) do
      {:error, _err} ->
        []

      {:ok, content} ->
        content
        |> String.split("\n")
        |> Enum.map(&String.split(&1, "="))
        |> Enum.map(&List.to_tuple/1)
        |> Enum.filter(&(elem(&1, 0) in keys))
        |> Enum.into(%{})
    end
  end

  defp remap_keys(toggle), do: {get_key(toggle), elem(toggle, 0)}

  defp get_key({toggle, opts}), do: opts[:key] || toggle_key(toggle)

  defp toggle_key(key) do
    key
    |> Atom.to_string()
    |> String.replace("?", "")
    |> String.upcase()
  end

  defp to_boolean("true"), do: true
  defp to_boolean(_env), do: false
end
