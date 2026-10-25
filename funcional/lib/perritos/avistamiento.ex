defmodule Perritos.Avistamiento do
  @moduledoc "Un perrito registrado (dato puro, sin lógica)."
  @derive {Jason.Encoder, only: [:id, :nombre, :raza, :colores, :fecha]}
  defstruct [:id, :nombre, :raza, :colores, :fecha]
end
