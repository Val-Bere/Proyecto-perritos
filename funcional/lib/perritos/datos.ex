defmodule Perritos.Datos do
  @moduledoc """
  Cáscara: lee los avistamientos del backend del P1 por HTTP (Opción B,
  Apéndice C.9) y los convierte en `Perritos.Avistamiento`. El núcleo de
  cada funcionalidad nunca llama a este módulo directo; lo hace a través
  del router, y nunca sabe de dónde vinieron los datos.

  La URL del backend llega por variable de ambiente: dentro de Docker,
  `BACKEND_URL` usa el **nombre del servicio** (http://backend:8000), nunca
  localhost.
  """

  alias Perritos.Avistamiento

  @doc """
  Trae todos los avistamientos. Regresa `{:ok, lista}` o `{:error, razon}`.
  """
  def avistamientos do
    url = backend_url() <> "/perritos/"

    case Req.get(url) do
      {:ok, %Req.Response{status: 200, body: lista}} when is_list(lista) ->
        {:ok, Enum.map(lista, &a_avistamiento/1)}

      {:ok, %Req.Response{status: status}} ->
        {:error, {:status, status}}

      {:error, razon} ->
        {:error, razon}
    end
  end

  defp backend_url do
    System.get_env("BACKEND_URL", "http://backend:8000")
  end

  # Req ya decodificó el JSON: son mapas con llaves de texto.
  # La forma exacta la expone el backend en GET /perritos/ (ver
  # backend/app/schemas.py: PerritoOut).
  defp a_avistamiento(m) do
    %Avistamiento{
      id: m["id"],
      nombre: m["nombre"],
      raza: m["raza_nombre"],
      colores: Enum.map(m["colores"], &color_a_atomo/1),
      lat: to_float(m["latitud"]),
      lon: to_float(m["longitud"]),
      foto: m["foto_archivo"],
      fecha: parse_fecha(m["fecha_registro"])
    }
  end

  defp color_a_atomo(%{"nombre" => nombre}) do
    nombre
    |> String.downcase()
    |> String.replace(" / ", "_")
    |> String.replace(" ", "_")
    |> String.to_atom()
  end

  defp to_float(n) when is_float(n), do: n
  defp to_float(n) when is_integer(n), do: n * 1.0

  defp parse_fecha(texto) do
    case NaiveDateTime.from_iso8601(texto) do
      {:ok, fecha} -> fecha
      {:error, _} -> DateTime.from_iso8601(texto) |> elem(1) |> DateTime.to_naive()
    end
  end
end
