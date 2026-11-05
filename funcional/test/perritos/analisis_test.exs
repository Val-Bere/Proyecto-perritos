defmodule Perritos.AnalisisTest do
  use ExUnit.Case, async: true
  doctest Perritos.Analisis

  alias Perritos.{Analisis, Avistamiento}

  @ahora ~N[2026-10-26 12:00:00]

  defp perro(id, fecha, lat \\ 25.4231, lon \\ -101.0000) do
    %Avistamiento{
      id: id,
      nombre: "Perro #{id}",
      raza: nil,
      colores: [:negro],
      lat: lat,
      lon: lon,
      foto: "sin-foto.jpg",
      fecha: fecha
    }
  end

  test "caso borde 1: lista vacía produce lista vacía" do
    assert Analisis.perdidos([], 10, @ahora) == []
    assert Analisis.perdidos_por_zona([], 10, @ahora, 500) == []
  end

  test "caso borde 2: si todos se vieron hace poco, no hay perdidos" do
    recientes = [perro(1, ~N[2026-10-25 09:00:00]), perro(2, ~N[2026-10-26 08:00:00])]
    assert Analisis.perdidos(recientes, 10, @ahora) == []
  end

  test "caso borde 3: justo n días cuenta como perdido (límite inclusivo)" do
    justo = perro(1, ~N[2026-10-16 23:59:00])
    un_dia_menos = perro(2, ~N[2026-10-17 00:01:00])

    ids = [justo, un_dia_menos] |> Analisis.perdidos(10, @ahora) |> Enum.map(& &1.id)
    assert ids == [1]
  end

  test "cuenta días de calendario, no horas" do
    assert Analisis.dias_sin_ver(~N[2026-10-25 23:59:00], ~N[2026-10-26 00:01:00]) == 1
    assert Analisis.dias_sin_ver(~N[2026-10-26 00:01:00], ~N[2026-10-26 23:59:00]) == 0
  end

  test "filtra los perdidos y los ordena del más antiguo al más reciente" do
    lista = [
      perro(1, ~N[2026-09-20 10:00:00]),
      perro(2, ~N[2026-10-25 10:00:00]),
      perro(3, ~N[2026-08-01 10:00:00]),
      perro(4, ~N[2026-10-01 10:00:00])
    ]

    ids = lista |> Analisis.perdidos(10, @ahora) |> Enum.map(& &1.id)
    assert ids == [3, 1, 4]
  end

  test "ignora avistamientos sin fecha en lugar de tronar" do
    lista = [perro(1, nil), perro(2, ~N[2026-08-01 10:00:00])]
    ids = lista |> Analisis.perdidos(10, @ahora) |> Enum.map(& &1.id)
    assert ids == [2]
  end

  test "perdido_desde/2 regresa una función que sirve con cualquier lista (orden superior)" do
    perdido? = Analisis.perdido_desde(30, @ahora)

    assert perdido?.(perro(1, ~N[2026-08-01 10:00:00]))
    refute perdido?.(perro(2, ~N[2026-10-20 10:00:00]))
  end

  test "ordenar/2 acepta cualquier comparador (orden superior)" do
    lista = [perro(1, ~N[2026-08-01 10:00:00]), perro(2, ~N[2026-09-01 10:00:00])]
    mas_reciente_primero = fn a, b -> NaiveDateTime.compare(a.fecha, b.fecha) != :lt end

    assert lista |> Analisis.ordenar(mas_reciente_primero) |> Enum.map(& &1.id) == [2, 1]
  end

  test "agrupa los perdidos por zona y pone primero la zona con más perros" do
    # p1 y p2 caen en la misma celda de 500 m; p3 está lejos
    p1 = perro(1, ~N[2026-08-01 10:00:00], 25.4231, -101.0000)
    p2 = perro(2, ~N[2026-09-01 10:00:00], 25.4232, -100.9995)
    p3 = perro(3, ~N[2026-08-15 10:00:00], 25.4500, -101.0300)

    [primera, segunda] = Analisis.perdidos_por_zona([p3, p2, p1], 10, @ahora, 500)

    assert primera.cantidad == 2
    assert Enum.map(primera.perros, & &1.id) == [1, 2]
    assert segunda.cantidad == 1
    assert Enum.map(segunda.perros, & &1.id) == [3]
    assert hd(primera.perros).dias_sin_ver == 86
    assert Map.has_key?(primera, :limites) and Map.has_key?(primera, :centro)
  end

  test "los perdidos sin coordenadas válidas no aparecen en ninguna zona" do
    sin_ubicacion = perro(1, ~N[2026-08-01 10:00:00], nil, nil)
    con_ubicacion = perro(2, ~N[2026-08-01 10:00:00])

    zonas = Analisis.perdidos_por_zona([sin_ubicacion, con_ubicacion], 10, @ahora, 500)

    assert [%{cantidad: 1, perros: [%{id: 2}]}] = zonas
  end

  test "verificacion extra de integracion de analisis" do
    assert is_list(Analisis.perdidos([], 10, @ahora))
  end

  test "con 0 días cuentan todos los que tienen fecha, del más antiguo al más reciente" do
    lista = [perro(1, ~N[2026-10-26 08:00:00]), perro(2, ~N[2026-08-01 10:00:00])]
    ids = lista |> Analisis.perdidos(0, @ahora) |> Enum.map(& &1.id)
    assert ids == [2, 1]
  end

  test "una fecha futura no cuenta como perdida" do
    assert Analisis.perdidos([perro(1, ~N[2026-10-30 10:00:00])], 10, @ahora) == []
  end

  test "con celdas más chicas los mismos perros quedan en zonas distintas" do
    p1 = perro(1, ~N[2026-08-01 10:00:00], 25.4231, -101.0000)
    p2 = perro(2, ~N[2026-08-01 10:00:00], 25.4232, -100.9995)

    assert length(Analisis.perdidos_por_zona([p1, p2], 10, @ahora, 500)) == 1
    assert length(Analisis.perdidos_por_zona([p1, p2], 10, @ahora, 250)) == 2
  end
end