defmodule Perritos.Analisis do
  @moduledoc """
  Núcleo puro de la Funcionalidad 7: **perros perdidos de vista**.

  Dado un conjunto de avistamientos, encuentra los que no se han vuelto a
  reportar en `n` días, los ordena del más antiguo al más reciente y los
  agrupa por zona (la misma cuadrícula de la funcionalidad de zonas).

  Todas las funciones son puras: no consultan la base de datos ni leen el
  reloj. La fecha de "hoy" llega como argumento (`ahora`); el router, que es
  cáscara, es quien la lee.

  Autoría: Alma Bujanda (primera versión del filtro y el ordenamiento);
  integrada al esqueleto del servicio, con agrupación por zona y endpoint.
  """

  alias Perritos.Zonas

  @doc """
  Días de calendario que han pasado desde `fecha` hasta `ahora`.
  Regresa `:desconocido` si no hay una fecha válida.

      iex> Perritos.Analisis.dias_sin_ver(~N[2026-10-18 23:59:00], ~N[2026-10-19 00:01:00])
      1
      iex> Perritos.Analisis.dias_sin_ver(~N[2026-10-09 12:00:00], ~N[2026-10-19 08:00:00])
      10
      iex> Perritos.Analisis.dias_sin_ver(nil, ~N[2026-10-19 08:00:00])
      :desconocido
  """
  def dias_sin_ver(%NaiveDateTime{} = fecha, %NaiveDateTime{} = ahora) do
    Date.diff(NaiveDateTime.to_date(ahora), NaiveDateTime.to_date(fecha))
  end

  def dias_sin_ver(_fecha, _ahora), do: :desconocido

  @doc """
  **Regresa una función**: el predicado que dice si un avistamiento cuenta
  como "perdido de vista" (lleva `dias` o más sin reportarse, visto desde `ahora`).

      iex> perdido? = Perritos.Analisis.perdido_desde(10, ~N[2026-10-26 12:00:00])
      iex> perdido?.(%{fecha: ~N[2026-08-01 10:00:00]})
      true
      iex> perdido?.(%{fecha: ~N[2026-10-25 10:00:00]})
      false
      iex> perdido?.(%{fecha: nil})
      false
  """
  def perdido_desde(dias, ahora) when is_integer(dias) and dias >= 0 do
    fn
      %{fecha: fecha} -> es_perdido(dias_sin_ver(fecha, ahora), dias)
      _otro -> false
    end
  end

  defp es_perdido(:desconocido, _dias), do: false
  defp es_perdido(transcurridos, dias), do: transcurridos >= dias

  @doc """
  **Recursión explícita** y **recibe una función**: se queda con los elementos
  para los que `predicado` regresa `true`.

      iex> Perritos.Analisis.filtrar([1, 2, 3, 4], &(rem(&1, 2) == 0))
      [2, 4]
      iex> Perritos.Analisis.filtrar([], &(&1 > 0))
      []
  """
  def filtrar([], _predicado), do: []

  def filtrar([cabeza | resto], predicado) when is_function(predicado, 1) do
    incluir(predicado.(cabeza), cabeza, filtrar(resto, predicado))
  end

  defp incluir(true, elemento, resto), do: [elemento | resto]
  defp incluir(false, _elemento, resto), do: resto

  @doc """
  Comparador para `ordenar/2`: el avistamiento más antiguo va primero.

      iex> Perritos.Analisis.mas_antiguo_primero(%{fecha: ~N[2026-10-01 08:00:00]}, %{fecha: ~N[2026-10-05 08:00:00]})
      true
      iex> Perritos.Analisis.mas_antiguo_primero(%{fecha: ~N[2026-10-05 08:00:00]}, %{fecha: ~N[2026-10-01 08:00:00]})
      false
  """
  def mas_antiguo_primero(%{fecha: a}, %{fecha: b}), do: NaiveDateTime.compare(a, b) != :gt

  @doc """
  **Recibe una función** de comparación y ordena con ella.

      iex> viejos = [%{fecha: ~N[2026-10-05 08:00:00]}, %{fecha: ~N[2026-10-01 08:00:00]}]
      iex> Perritos.Analisis.ordenar(viejos, &Perritos.Analisis.mas_antiguo_primero/2)
      [%{fecha: ~N[2026-10-01 08:00:00]}, %{fecha: ~N[2026-10-05 08:00:00]}]
  """
  def ordenar(avistamientos, comparador) when is_function(comparador, 2) do
    Enum.sort(avistamientos, comparador)
  end

  @doc """
  Los avistamientos que llevan `dias` o más sin reportarse, del más antiguo
  al más reciente.

      iex> lista = [
      ...>   %{id: 1, fecha: ~N[2026-08-01 10:00:00]},
      ...>   %{id: 2, fecha: ~N[2026-10-25 10:00:00]},
      ...>   %{id: 3, fecha: ~N[2026-07-01 10:00:00]}
      ...> ]
      iex> Perritos.Analisis.perdidos(lista, 10, ~N[2026-10-26 12:00:00]) |> Enum.map(& &1.id)
      [3, 1]
  """
  def perdidos(avistamientos, dias, ahora) do
    avistamientos
    |> filtrar(perdido_desde(dias, ahora))
    |> ordenar(&mas_antiguo_primero/2)
  end

  @doc """
  Agrupa los perros perdidos por zona de una cuadrícula de `metros` metros.
  Cada zona trae su `centro` y `limites` (listos para que el frontend la pinte)
  y la lista de `perros`, del más antiguo al más reciente. Los avistamientos
  sin coordenadas válidas no pertenecen a ninguna zona y se omiten.
  Las zonas con más perros perdidos van primero.
  """
  def por_zona(perdidos, ahora, metros \\ 500) do
    paso = Zonas.metros_a_grados(metros)
    proyectar = Zonas.proyeccion_celda(metros)

    perdidos
    |> Enum.group_by(&celda(&1, proyectar), &ficha(&1, ahora))
    |> Enum.flat_map(&armar_zona(&1, paso))
    |> Enum.sort_by(&{-&1.cantidad, &1.celda.fila, &1.celda.col})
  end

  @doc """
  Función principal: perros perdidos de vista agrupados por zona, componiendo
  las funciones anteriores con `|>`.
  """
  def perdidos_por_zona(avistamientos, dias, ahora, metros \\ 500) do
    avistamientos
    |> perdidos(dias, ahora)
    |> por_zona(ahora, metros)
  end

  defp celda(avistamiento, proyectar) do
    avistamiento
    |> Zonas.extraer_coordenadas()
    |> celda_de(proyectar)
  end

  defp celda_de({:ok, coordenadas}, proyectar), do: proyectar.(coordenadas)
  defp celda_de(:invalido, _proyectar), do: :sin_ubicacion

  defp ficha(%{fecha: fecha} = avistamiento, ahora) do
    avistamiento
    |> Map.take([:id, :nombre, :lat, :lon, :foto, :fecha])
    |> Map.put(:dias_sin_ver, dias_sin_ver(fecha, ahora))
  end

  defp armar_zona({:sin_ubicacion, _perros}, _paso), do: []

  defp armar_zona({celda, perros}, paso) do
    [Map.put(Zonas.construir_zona({celda, length(perros)}, paso), :perros, perros)]
  end
end
