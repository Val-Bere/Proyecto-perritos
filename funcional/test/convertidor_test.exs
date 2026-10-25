defmodule Perritos.ConvertidorTest do
  use ExUnit.Case, async: true
  doctest Perritos.Convertidor

  alias Perritos.Convertidor

  @razas %{1 => "criollo", 2 => "pug"}

  test "convierte un perrito completo" do
    api = %{
      "id" => 7, "nombre" => "Luna", "id_raza" => 1,
      "fecha_registro" => "2026-10-20T10:30:00",
      "colores" => [%{"nombre" => "Negro"}]
    }
    a = Convertidor.desde_api(api, @razas)
    assert {a.id, a.nombre, a.raza, a.colores} == {7, "Luna", "criollo", ["Negro"]}
    assert a.fecha == ~N[2026-10-20 10:30:00]
  end

  test "borde: sin raza queda en nil" do
    a = Convertidor.desde_api(%{"nombre" => "X", "id_raza" => nil, "colores" => []}, @razas)
    assert a.raza == nil
  end

  test "borde: raza con id que no está en el catálogo queda en nil" do
    a = Convertidor.desde_api(%{"nombre" => "X", "id_raza" => 99, "colores" => []}, @razas)
    assert a.raza == nil
  end

  test "borde: fecha ausente o inválida queda en nil" do
    assert Convertidor.desde_api(%{"colores" => []}, @razas).fecha == nil
    assert Convertidor.desde_api(%{"fecha_registro" => "ayer", "colores" => []}, @razas).fecha == nil
  end

  test "sin lista de colores devuelve lista vacía" do
    assert Convertidor.desde_api(%{"nombre" => "X"}, @razas).colores == []
  end
end
