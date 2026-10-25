defmodule Perritos.Estadisticas do
  @moduledoc """
  Núcleo PURO de estadísticas: cuenta avistamientos por color, raza o día
  y devuelve el top N. No lee BD, no usa HTTP, no guarda estado.
  """

  alias Perritos.Avistamiento

  # ---------- 1) Función que DEVUELVE otra función (HOF #2) ----------
  # Cada clausula (pattern matching) devuelve "cómo sacar las claves"
  # de un avistamiento.
  def claves_por(:color), do: fn %Avistamiento{colores: colores} -> colores end
  def claves_por(:raza), do: fn %Avistamiento{raza: raza} -> [nombre_raza(raza)] end
  def claves_por(:dia), do: fn %Avistamiento{fecha: f} -> [NaiveDateTime.to_date(f)] end

  # Pattern matching sobre nil: raza opcional
  defp nombre_raza(nil), do: "raza desconocida"
  defp nombre_raza(""), do: "raza desconocida"
  defp nombre_raza(raza), do: raza

  # ---------- 2) Función que RECIBE otra función (HOF #1) ----------
  @doc """
  Cuenta cuántas veces aparece cada clave. `claves` es una función que,
  dado un avistamiento, devuelve la lista de claves que le tocan.

  ## Ejemplo

      iex> alias Perritos.Avistamiento
      iex> lista = [
      ...>   %Avistamiento{colores: [:café, :blanco]},
      ...>   %Avistamiento{colores: [:café]}
      ...> ]
      iex> Perritos.Estadisticas.contar_por(lista, Perritos.Estadisticas.claves_por(:color))
      %{blanco: 1, café: 2}
  """
  def contar_por(avistamientos, claves) do
    Enum.reduce(avistamientos, %{}, fn a, acc ->
      Enum.reduce(claves.(a), acc, fn k, acc2 -> Map.update(acc2, k, 1, &(&1 + 1)) end)
    end)
  end

  # ---------- 3) Ordenar: más repetido primero; empate -> orden alfabético ----------
  def ordenar(conteos) do
    conteos
    |> Map.to_list()
    |> Enum.sort_by(fn {clave, n} -> {-n, to_string(clave)} end)
  end

  # ---------- 4) Recursión escrita a mano ----------
  @doc """
  Toma los primeros `n` elementos de una lista (recursión explícita).

      iex> Perritos.Estadisticas.primeros([1, 2, 3, 4], 2)
      [1, 2]
      iex> Perritos.Estadisticas.primeros([1], 5)
      [1]
  """
  def primeros(_lista, 0), do: []
  def primeros([], _n), do: []
  def primeros([h | t], n) when n > 0, do: [h | primeros(t, n - 1)]
  def primeros(_lista, _n), do: []

  # ---------- 5) Pipeline completo ----------
  @doc """
  Top `n` de `por` (:color | :raza | :dia). Devuelve lista de `{clave, total}`.

      iex> alias Perritos.Avistamiento
      iex> lista = [%Avistamiento{raza: "pug"}, %Avistamiento{raza: nil}, %Avistamiento{raza: "pug"}]
      iex> Perritos.Estadisticas.top(lista, :raza, 1)
      [{"pug", 2}]
  """
  def top(avistamientos, por, n) do
    avistamientos
    |> contar_por(claves_por(por))
    |> ordenar()
    |> primeros(n)
  end
end
