defmodule Exred.Library.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exred_library,
      version: "0.1.6",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
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
      {:uuid, "~> 1.1"},
      {:conform, "~> 2.2"}
    ]
  end
end
