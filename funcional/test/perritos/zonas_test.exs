defmodule Perritos.ZonasTest do
  use ExUnit.Case, async: true
  doctest Perritos.Zonas

  alias Perritos.{Avistamiento, Zonas}

  defp perro(id, lat, lon) do
    %Avistamiento{
      id: id,
      nombre: "Perro #{id}",
      raza: nil,
      colores: [:negro],
      lat: lat,
      lon: lon,
      foto: "foto.jpg",
      fecha: ~N[2026-10-20 10:00:00]
    }
  end

  test "caso borde 1: lista vacía devuelve lista vacía" do
    assert Zonas.concentracion([]) == []
  end

  test "caso borde 2: ignora avistamientos con coordenadas nulas o sin lat/lon" do
    invalidos = [perro(1, nil, -101.0), perro(2, 25.42, nil), %{id: 3}]
    assert Zonas.concentracion(invalidos, 500) == []
  end

  test "agrupa perros cercanos en la misma celda y ordena de mayor a menor" do
    p1 = perro(1, 25.4231, -101.0021)
    p2 = perro(2, 25.4232, -101.0022)
    p3 = perro(3, 25.4500, -101.0300)

    zonas = Zonas.concentracion([p1, p2, p3], 500)

    assert length(zonas) == 2
    [primera, segunda] = zonas

    assert primera.cantidad == 2
    assert primera.nivel == :media
    assert segunda.cantidad == 1
    assert segunda.nivel == :baja
  end

  test "caso borde 3: coordenadas en el límite exacto caen en celdas distintas" do
    p1 = perro(1, 25.419999, -101.005)
    p2 = perro(2, 25.420000, -101.005)

    zonas = Zonas.concentracion([p1, p2], 1110)

    assert length(zonas) == 2
    filas = zonas |> Enum.map(& &1.celda.fila) |> Enum.sort()
    assert filas == [2541, 2542]
  end

  test "filtra recursivamente las zonas con menos del mínimo indicado" do
    avistamientos = [
      perro(1, 25.421, -101.001),
      perro(2, 25.421, -101.001),
      perro(3, 25.421, -101.001),
      perro(4, 25.480, -101.050)
    ]

    zonas = Zonas.concentracion(avistamientos, 500, 3)

    assert length(zonas) == 1
    assert hd(zonas).cantidad == 3
  end

  test "contar_por_celda recibe cualquier función de proyección (orden superior)" do
    avistamientos = [perro(1, 25.1, -101.1), perro(2, 25.9, -101.9)]
    fn_grado_entero = fn {lat, lon} -> {trunc(lat), trunc(lon)} end

    assert Zonas.contar_por_celda(avistamientos, fn_grado_entero) == %{{25, -101} => 2}
  end
end