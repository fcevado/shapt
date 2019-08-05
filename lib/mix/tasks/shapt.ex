defmodule Mix.Tasks.Shapt do
  use Mix.Task

  @shortdoc "Shows Shapt tasks help info"
  @moduledoc """
  Prints help info for Shapt tasks. Doesn't accept parameters.
  """

  def run(args) do
    case args do
      [] ->
        help()

      _ ->
        Mix.raise("Invalid arguments, expected: mix shapt")
    end
  end

  defp help do
    Mix.shell().info("Tasks to make it easier to use Shapt.")
    Mix.shell().info("Available tasks:\n")
    Mix.Tasks.Help.run(["--search", "shapt."])
  end
end
