defmodule Exred.Library.Mixfile do
  use Mix.Project

  @description "Library application for Exred. Handles storage and access of flows."

  def project do
    [
      app: :exred_library,
      version: "0.1.2",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      description: @description,
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Exred.Library.Application, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.0"},
      {:postgrex, "~> 0.13.4"},
      {:elixir_uuid, "~> 1.2"},
      {:conform, "~> 2.2"},
      {:ex_doc, "~> 0.18.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Zsolt Keszthelyi"],
      links: %{
        "GitHub" => "https://github.com/exredorg/exred_library",
        "Exred" => "http://exred.org"
      },
      files: ["lib", "mix.exs", "README.md", "LICENSE"]
    }
  end
end
