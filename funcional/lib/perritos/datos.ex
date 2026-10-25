defmodule Perritos.Datos do
  @moduledoc """
  SHELL: lee los perritos del backend del proyecto 1 (opción B del PDF)
  y los convierte con el núcleo puro `Perritos.Convertidor`.

  La dirección del backend sale de la variable de entorno BACKEND_URL.
  """
  alias Perritos.Convertidor

  def avistamientos do
    base = System.get_env("BACKEND_URL") || "http://localhost:8000"

    with {:ok, perritos} <- obtener(base <> "/perritos/"),
         {:ok, razas} <- obtener(base <> "/catalogos/razas") do
      razas_por_id = Map.new(razas, fn r -> {r["id"], r["nombre"]} end)
      {:ok, Enum.map(perritos, &Convertidor.desde_api(&1, razas_por_id))}
    end
  end

  defp obtener(url) do
    case Req.get(url) do
      {:ok, %{status: 200, body: cuerpo}} when is_list(cuerpo) -> {:ok, cuerpo}
      {:ok, respuesta} -> {:error, {:respuesta_inesperada, respuesta.status}}
      {:error, razon} -> {:error, {:sin_conexion, razon}}
    end
  end
end
