defmodule Funcional.MixProject do
  use Mix.Project

  def project do
    [
      app: :funcional,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Perritos.Application, []}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.16"},
      {:bandit, "~> 1.5"},
      {:jason, "~> 1.4"},

      # Opción B: el servicio Elixir lee los avistamientos a través del
      # backend del P1 por HTTP (no se conecta directo a la base de datos).
      {:req, "~> 0.5"},

      # Opcional, sólo para generar documentación:
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    # mix test NO debe arrancar la aplicación: si la arranca, Perritos.Datos
    # intenta hablar con el backend y las pruebas del núcleo fallan aunque
    # el núcleo esté bien. Las pruebas del núcleo arman los structs a mano.
    [test: "test --no-start"]
  end
end
