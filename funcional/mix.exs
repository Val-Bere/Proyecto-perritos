defmodule Perritos.MixProject do
  use Mix.Project

  def project do
    [
      app: :perritos,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # "--no-start": los tests del núcleo puro no necesitan levantar el servidor
      aliases: [test: "test --no-start"]
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {Perritos.Application, []}]
  end

  defp deps do
    [
      {:plug, "~> 1.16"},
      {:bandit, "~> 1.5"},
      {:jason, "~> 1.4"},
      {:req, "~> 0.5"}
    ]
  end
end
