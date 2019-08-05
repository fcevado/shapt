defmodule Mix.Tasks.Shapt.Expired do
  use Mix.Task

  @shortdoc "Expose expired keys"
  @moduledoc """
  This task verify if the toggles of the informed Module is expired.
  Parameters:
  - `--module` or `-m`: Accepts one or more modules as parameter to verify the expired toggles. Modules are separated by a comma.
  - `--strict` or `-s`: Instead of just returning the expired toggles.

  Example:

  `mix shapt.expired -m MyToggles,MyFlippers`

  `mix shapt.expired -sm MyToggles`
  """

  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        strict: [strict: :boolean, module: :string],
        aliases: [s: :strict, m: :module]
      )

    evaluate(opts[:strict], opts[:module])
  end

  defp evaluate(true, modules) do
    expired = expired_toggles(modules)

    if Enum.any?(expired) do
      message = build_message(expired)

      Mix.raise("Expired keys.\n" <> message)
    end
  end

  defp evaluate(nil, modules) do
    expired = expired_toggles(modules)

    if Enum.any?(expired) do
      Mix.shell().info("Expired keys.")
      Mix.shell().info(build_message(expired))
    end
  end

  defp expired_toggles(modules) do
    modules
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&Module.concat([&1]))
    |> Enum.filter(&Code.ensure_loaded?/1)
    |> Enum.map(&{&1, &1.expired_toggles()})
  end

  defp build_message(expired) do
    expired
    |> Enum.map(&message/1)
    |> Enum.join("\n")
  end

  defp message({m, t}), do: "module: #{inspect(m)}, toggles: #{inspect(t)}"
end
