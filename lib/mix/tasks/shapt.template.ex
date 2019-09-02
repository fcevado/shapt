defmodule Mix.Tasks.Shapt.Template do
  use Mix.Task

  @shortdoc "Output a template of a configuration file for a Module"
  @moduledoc """
  This task output the template of a configuration for a Module.
  The template type is defined by the Adapter configured in the module.
  Parameters:
  - `--module` or `-m`(required): Accepts a module as parameter to output a template to it's adapter.
  - `--file` or `-f`: Accepts a filename as parameter to write the template to. If it's missing, will outpout to terminal.

  Example:

  `mix shapt.expired -m MyToggles`

  `mix shapt.expired -m MyToggles -f template.env`
  """

  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        strict: [module: :string, file: :string],
        aliases: [m: :module, f: :file]
      )

    opts[:module]
    |> generate_template()
    |> do_template(opts[:file])
  end

  defp do_template(template, nil) do
    Mix.shell().info(template)
  end

  defp do_template(template, file) do
    File.write(file, template)
  end

  defp generate_template(module) do
    module =
      module
      |> String.trim()
      |> List.wrap()
      |> Module.concat()

    if Code.ensure_loaded?(module) do
      module.start_link([])
      module.template()
    else
      Mix.raise("#{module} is not available.")
    end
  end
end
