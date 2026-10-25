defmodule Perritos.Avistamiento do
  @moduledoc """
  El struct que usa el **núcleo**: un avistamiento ya convertido a datos de
  Elixir, sin importar si vino de la base de datos o del backend del P1
  (eso lo decide `Perritos.Datos`, que es cáscara).
  """

  @derive {Jason.Encoder, only: [:id, :nombre, :raza, :colores, :lat, :lon, :foto, :fecha]}
  defstruct [:id, :nombre, :raza, :colores, :lat, :lon, :foto, :fecha]

  @type t :: %__MODULE__{
          id: integer(),
          nombre: String.t(),
          raza: String.t() | nil,
          colores: [atom()],
          lat: float(),
          lon: float(),
          foto: String.t(),
          fecha: NaiveDateTime.t()
        }
end
