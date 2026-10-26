defmodule Refugio.Analisis do
  @doc """
  Filtra perritos que no se han reportado en 'dias_inactivo',
  los ordena del más antiguo al más reciente y los agrupa por zona.
  """
  def perros_perdidos_por_zona(perritos, dias_inactivo, fecha_actual \\ NaiveDateTime.utc_now()) do
    limite_segundos = dias_inactivo * 24 * 60 * 60

    perritos
   
    |> Enum.filter(fn perrito ->
      NaiveDateTime.diff(fecha_actual, perrito.ultima_vez, :second) >= limite_segundos
    end)
    
    |> Enum.sort_by(& &1.ultima_vez, {:asc, NaiveDateTime})
    
    |> Enum.group_by(& &1.zona)
  end
end