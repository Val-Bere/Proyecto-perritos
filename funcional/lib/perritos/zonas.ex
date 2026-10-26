defmodule Perritos.Zonas do
  @moduledoc """
  Núcleo puro de la Funcionalidad 4: Zonas de concentración.
  Divide la ciudad en una cuadrícula en metros y cuenta cuántos perros hay en cada celda.
  """

  @metros_por_grado 111_000.0

  @doc """
  Convierte un tamaño en metros al tamaño de paso en grados geográficos.
  Usa cláusulas múltiples y guardas.

  iex> Perritos.Zonas.metros_a_grados(1110)
  0.01
  iex> Perritos.Zonas.metros_a_grados(-5)
  0.004505
  """
  def metros_a_grados(metros) when is_number(metros) and metros > 0 do
    Float.round(metros / @metros_por_grado, 6)
  end

  def metros_a_grados(_), do: Float.round(500 / @metros_por_grado, 6)

  @doc """
  Orden superior (REGRESA UNA FUNCIÓN):
  Recibe el tamaño de celda en metros y regresa una función pura que convierte
  cualquier coordenada `{lat, lon}` en su celda `{fila, col}`.

  iex> proyectar = Perritos.Zonas.proyeccion_celda(1110)
  iex> proyectar.({25.423, -101.004})
  {2542, -10101}
  """
  def proyeccion_celda(tamano_metros) do
    paso = metros_a_grados(tamano_metros)

    fn {lat, lon} ->
      {floor(lat / paso), floor(lon / paso)}
    end
  end

  @doc """
  Extrae las coordenadas `{lat, lon}` de un avistamiento usando pattern matching
  y cláusulas múltiples en lugar de `if` o `cond`.

  iex> Perritos.Zonas.extraer_coordenadas(%{lat: 25.42, lon: -101.0})
  {:ok, {25.42, -101.0}}
  iex> Perritos.Zonas.extraer_coordenadas(%{lat: nil, lon: -101.0})
  :invalido
  """
  def extraer_coordenadas(%{lat: lat, lon: lon})
      when is_number(lat) and is_number(lon),
      do: {:ok, {lat, lon}}

  def extraer_coordenadas(%{latitud: lat, longitud: lon})
      when is_number(lat) and is_number(lon),
      do: {:ok, {lat, lon}}

  def extraer_coordenadas(_), do: :invalido

  @doc """
  Clasifica el nivel de concentración de una celda usando cláusulas múltiples.

  iex> Perritos.Zonas.nivel_concentracion(1)
  :baja
  iex> Perritos.Zonas.nivel_concentracion(3)
  :media
  iex> Perritos.Zonas.nivel_concentracion(6)
  :alta
  """
  def nivel_concentracion(cantidad) when cantidad >= 5, do: :alta
  def nivel_concentracion(cantidad) when cantidad >= 2, do: :media
  def nivel_concentracion(cantidad) when cantidad >= 1, do: :baja
  def nivel_concentracion(_), do: :vacia

  @doc """
  RECURSIÓN EXPLÍCITA:
  Filtra recursivamente las zonas que tienen al menos `minimo` perros.

  iex> zonas = [%{cantidad: 1}, %{cantidad: 4}, %{cantidad: 2}]
  iex> Perritos.Zonas.filtrar_por_minimo(zonas, 2)
  [%{cantidad: 4}, %{cantidad: 2}]
  """
  def filtrar_por_minimo([], _minimo), do: []

  def filtrar_por_minimo([%{cantidad: c} = zona | resto], minimo) when c >= minimo do
    [zona | filtrar_por_minimo(resto, minimo)]
  end

  def filtrar_por_minimo([_zona | resto], minimo) do
    filtrar_por_minimo(resto, minimo)
  end

  @doc """
  Orden superior (RECIBE UNA FUNCIÓN):
  Recibe los avistamientos y la función `fn_celda`, procesa perezosamente con `Stream`
  y agrupa/cuenta con `Enum.reduce`.
  """
  def contar_por_celda(avistamientos, fn_celda) when is_function(fn_celda, 1) do
    avistamientos
    |> Stream.map(&extraer_coordenadas/1)
    |> Stream.filter(&match?({:ok, _}, &1))
    |> Stream.map(fn {:ok, coords} -> fn_celda.(coords) end)
    |> Enum.reduce(%{}, fn celda, acumulador ->
      Map.update(acumulador, celda, 1, &(&1 + 1))
    end)
  end

  @doc """
  Construye el mapa con las coordenadas listas para que el frontend sólo pinte la celda.
  """
  def construir_zona({{fila, col}, cantidad}, paso_grados) do
    lat_min = Float.round(fila * paso_grados, 6)
    lat_max = Float.round((fila + 1) * paso_grados, 6)
    lon_min = Float.round(col * paso_grados, 6)
    lon_max = Float.round((col + 1) * paso_grados, 6)

    %{
      celda: %{fila: fila, col: col},
      cantidad: cantidad,
      nivel: nivel_concentracion(cantidad),
      centro: %{
        lat: Float.round((lat_min + lat_max) / 2.0, 6),
        lon: Float.round((lon_min + lon_max) / 2.0, 6)
      },
      limites: %{
        lat_min: lat_min,
        lat_max: lat_max,
        lon_min: lon_min,
        lon_max: lon_max
      }
    }
  end

  @doc """
  Función principal: calcula las zonas de concentración componiendo funciones con `|>`.
  """
  def concentracion(avistamientos, tamano_metros \\ 500, minimo \\ 1) do
    paso = metros_a_grados(tamano_metros)
    proyectar = proyeccion_celda(tamano_metros)

    avistamientos
    |> contar_por_celda(proyectar)
    |> Enum.map(&construir_zona(&1, paso))
    |> filtrar_por_minimo(minimo)
    |> Enum.sort_by(&{&1.cantidad, &1.celda.fila, &1.celda.col}, :desc)
  end
end