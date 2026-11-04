defmodule Perritos.Analisis do
  @moduledoc """
  Módulo para el análisis funcional de avistamientos de perritos.
  """

  @doc """
  Filtra avistamientos que no han tenido nuevos reportes en un periodo de 'dias_inactivo',
  respecto a 'fecha_referencia', y los ordena.

  ## Doctest
  
      iex> fecha_ref = ~N[2026-10-26 12:00:00]
      iex> avistamientos = [
      ...>   %{id: 1, fecha: ~N[2026-08-01 10:00:00], lat: 25.42, lon: -101.00},
      ...>   %{id: 2, fecha: ~N[2026-10-25 10:00:00], lat: 25.43, lon: -101.01}
      ...> ]
      iex> Perritos.Analisis.perros_perdidos_de_vista(avistamientos, 10, fecha_ref)
      [
        %{id: 1, fecha: ~N[2026-08-01 10:00:00], lat: 25.42, lon: -101.00}
      ]
  """
  def perros_perdidos_de_vista(avistamientos, dias_inactivo, fecha_referencia) do
    avistamientos
    |> filtrar_por_inactividad(dias_inactivo, fecha_referencia)
    |> ordenar_por_fecha_ascendente()
  end

  # Función de filtrado explícita usando recursión
  def filtrar_por_inactividad([], _dias, _fecha_ref), do: []

  def filtrar_por_inactividad([avistamiento | resto], dias, fecha_ref) do
    limite_segundos = dias * 24 * 60 * 60
    diferencia = NaiveDateTime.diff(fecha_ref, avistamiento.fecha, :second)

    if diferencia >= limite_segundos do
      [avistamiento | filtrar_por_inactividad(resto, dias, fecha_ref)]
    else
      filtrar_por_inactividad(resto, dias, fecha_ref)
    end
  end

  # Función de ordenamiento explícita sobre fechas
  def ordenar_por_fecha_ascendente(avistamientos) do
    Enum.sort_by(avistamientos, fn a -> a.fecha end, {:asc, NaiveDateTime})
  end
end