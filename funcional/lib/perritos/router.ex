defmodule Perritos.Router do
  @moduledoc """
  Cáscara HTTP: traduce peticiones en llamadas al núcleo.

  Cada integrante agrega aquí la ruta de su funcionalidad, siguiendo el
  mismo patrón que `/f/salud`: leer la petición -> traer los datos con
  `Perritos.Datos` -> llamar a su módulo del núcleo -> responder JSON.
  Las rutas se escriben con el prefijo /f/..., porque el proxy (nginx)
  conserva ese prefijo (ver proxy/nginx.conf).
  """
  use Plug.Router

  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason

  plug :match
  plug :dispatch

  get "/f/salud" do
    send_resp(conn, 200, "ok")
  end

  # Ejemplo de cómo se conecta una funcionalidad real (reemplacen cuando
  # agreguen la suya): trae los avistamientos y responde la lista cruda,
  # sólo para confirmar que la cáscara ya habla con el backend del P1.
  get "/f/avistamientos" do
    case Perritos.Datos.avistamientos() do
      {:ok, avistamientos} ->
        cuerpo = Jason.encode!(avistamientos)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, cuerpo)

      {:error, _razon} ->
        send_resp(conn, 503, ~s({"error": "backend no disponible"}))
    end
  end

get "/f/zonas" do
    conn = fetch_query_params(conn)
    metros = parsear_entero(conn.query_params["metros"], 500)
    minimo = parsear_entero(conn.query_params["minimo"], 1)

    case Perritos.Datos.avistamientos() do
      {:ok, avistamientos} ->
        cuerpo =
          avistamientos
          |> Perritos.Zonas.concentracion(metros, minimo)
          |> Jason.encode!()

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, cuerpo)

      {:error, _} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(503, ~s({"error":"base de datos no disponible"}))
    end
  end

  match _ do
    send_resp(conn, 404, "no encontrado")
  end

defp parsear_entero(nil, defecto), do: defecto

  defp parsear_entero(texto, defecto) do
    case Integer.parse(texto) do
      {numero, ""} when numero > 0 -> numero
      _ -> defecto
    end
  end

end
