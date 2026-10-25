defmodule Perritos.Convertidor do
  @moduledoc """
  Núcleo PURO: traduce un perrito tal como lo manda el backend (mapa con
  llaves de texto) a nuestro struct `Perritos.Avistamiento`.

  No hace HTTP ni lee nada: recibe datos y devuelve datos.
  """
  alias Perritos.Avistamiento

  @doc """
  `razas` es un mapa `%{id => nombre}` (ver `/catalogos/razas`).

      iex> perrito = %{
      ...>   "id" => 1, "nombre" => "Max", "id_raza" => 2,
      ...>   "fecha_registro" => "2026-09-27T01:37:15",
      ...>   "colores" => [%{"nombre" => "Café"}, %{"nombre" => "Blanco"}]
      ...> }
      iex> a = Perritos.Convertidor.desde_api(perrito, %{2 => "pug"})
      iex> {a.nombre, a.raza, a.colores}
      {"Max", "pug", ["Café", "Blanco"]}
  """
  def desde_api(perrito, razas) do
    %Avistamiento{
      id: perrito["id"],
      nombre: perrito["nombre"],
      raza: nombre_de_raza(perrito["id_raza"], razas),
      colores: nombres_de_colores(perrito["colores"]),
      fecha: a_fecha(perrito["fecha_registro"])
    }
  end

  # Pattern matching: sin raza -> nil (el núcleo de estadísticas ya sabe qué hacer)
  defp nombre_de_raza(nil, _razas), do: nil
  defp nombre_de_raza(id, razas), do: Map.get(razas, id)

  defp nombres_de_colores(nil), do: []
  defp nombres_de_colores(colores), do: Enum.map(colores, fn c -> c["nombre"] end)

  defp a_fecha(nil), do: nil

  defp a_fecha(texto) do
    case NaiveDateTime.from_iso8601(texto) do
      {:ok, fecha} -> fecha
      {:error, _} -> nil
    end
  end
end
