defmodule Perritos.Router do
  @moduledoc "SHELL: traduce HTTP <-> llamadas al núcleo puro."
  use Plug.Router

  alias Perritos.{Datos, Estadisticas}

  plug :match
  plug :dispatch

  get "/f/salud" do
    mandar_json(conn, 200, %{status: "ok"})
  end

  get "/f/estadisticas" do
    conn = Plug.Conn.fetch_query_params(conn)
    por = parsear_por(conn.query_params["por"])
    n = parsear_n(conn.query_params["n"])

    resultado =
      Datos.avistamientos()
      |> Estadisticas.top(por, n)
      # to_string: las claves de :dia son Date y JSON no sabe codificarlas
      |> Enum.map(fn {clave, total} -> %{clave: to_string(clave), total: total} end)

    mandar_json(conn, 200, resultado)
  end

  match _ do
    mandar_json(conn, 404, %{error: "no encontrado"})
  end

  defp parsear_por("raza"), do: :raza
  defp parsear_por("dia"), do: :dia
  defp parsear_por(_), do: :color

  defp parsear_n(nil), do: 5
  defp parsear_n(texto) do
    case Integer.parse(texto) do
      {n, ""} when n >= 0 -> n
      _ -> 5
    end
  end

  defp mandar_json(conn, status, datos) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Jason.encode!(datos))
  end
end
