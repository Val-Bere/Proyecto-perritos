defmodule Perritos.Datos do
  @moduledoc """
  SHELL: de aquí salen los avistamientos.

  PENDIENTE: por ahora devuelve datos de ejemplo. Cuando el equipo defina
  la conexión (BD directa con Postgrex/MyXQL o vía backend con Req), solo
  hay que cambiar el cuerpo de `avistamientos/0`. El núcleo no se entera.
  """
  alias Perritos.Avistamiento

  def avistamientos do
    [
      %Avistamiento{id: 1, nombre: "Max", raza: "pug", colores: ["café", "blanco"], fecha: ~N[2026-10-20 10:00:00]},
      %Avistamiento{id: 2, nombre: "Luna", raza: nil, colores: ["negro"], fecha: ~N[2026-10-20 18:30:00]},
      %Avistamiento{id: 3, nombre: "Rocky", raza: "criollo", colores: ["café"], fecha: ~N[2026-10-21 09:15:00]}
    ]
  end
end
