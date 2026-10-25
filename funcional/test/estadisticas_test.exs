defmodule Perritos.EstadisticasTest do
  use ExUnit.Case, async: true
  doctest Perritos.Estadisticas

  alias Perritos.Avistamiento
  alias Perritos.Estadisticas, as: E

  defp av(attrs), do: struct(Avistamiento, attrs)

  test "cuenta colores y un perro con 2 colores cuenta en ambos" do
    lista = [av(colores: [:café, :blanco]), av(colores: [:café])]
    assert E.top(lista, :color, 5) == [{:café, 2}, {:blanco, 1}]
  end

  test "cuenta por raza" do
    lista = [av(raza: "pug"), av(raza: "pug"), av(raza: "criollo")]
    assert E.top(lista, :raza, 5) == [{"pug", 2}, {"criollo", 1}]
  end

  test "agrupa por día" do
    lista = [
      av(fecha: ~N[2026-10-20 10:00:00]),
      av(fecha: ~N[2026-10-20 18:00:00]),
      av(fecha: ~N[2026-10-21 09:00:00])
    ]
    assert E.top(lista, :dia, 5) == [{~D[2026-10-20], 2}, {~D[2026-10-21], 1}]
  end

  test "borde: lista vacía" do
    assert E.top([], :color, 5) == []
  end

  test "borde: raza nil o vacía se agrupa como 'raza desconocida'" do
    lista = [av(raza: nil), av(raza: ""), av(raza: "pug")]
    assert E.top(lista, :raza, 5) == [{"raza desconocida", 2}, {"pug", 1}]
  end

  test "borde: empate se desempata alfabéticamente" do
    lista = [av(colores: [:negro]), av(colores: [:blanco])]
    assert E.top(lista, :color, 5) == [{:blanco, 1}, {:negro, 1}]
  end

  test "borde: n mayor que la cantidad de grupos y n = 0" do
    lista = [av(colores: [:negro])]
    assert E.top(lista, :color, 99) == [{:negro, 1}]
    assert E.top(lista, :color, 0) == []
  end

  test "primeros/2 es recursiva y no revienta con n negativo" do
    assert E.primeros([1, 2, 3], 2) == [1, 2]
    assert E.primeros([1, 2, 3], -1) == []
  end

  test "funciona igual con un Stream como entrada" do
    flujo = Stream.map(1..3, fn _ -> av(colores: [:café]) end)
    assert E.top(flujo, :color, 1) == [{:café, 3}]
  end
end
