defmodule Shapt.MixProject do
  use Mix.Project

  @version "0.0.4"
  def project do
    [
      app: :shapt,
      version: @version,
      elixir: "~> 1.9",
      description: "An elixir feature toggle | flag | flipper library to make Blackbeard envy",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ] ++
      docs()
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.8.3", optional: true},
      {:jason, "~> 1.2.2", optional: true},
      {:poison, "~> 4.0.1", optional: true},
      {:credo, "~> 1.5.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21.1", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      name: "Shapt",
      source_ref: "v#{@version}",
      source_url: "https://github.com/fcevado/shapt",
      docs: [
        main: "usage",
        extras: ["USAGE.md", "CHANGELOG.md"]
      ]
    ]
  end

  def package do
    [
      licenses: ["Apache 2.0"],
      mainteiners: ["Flávio Moreira Vieira"],
      files: ["mix.exs", "lib", "LICENSE.md"],
      links: %{
        "Github" => "https://github.com/fcevado/shapt"
      }
    ]
  end
end
