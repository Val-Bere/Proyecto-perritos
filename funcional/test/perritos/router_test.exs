defmodule Perritos.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "Bienvenido a Perritos App")
  end

  get "/analisis" do
    avistamientos_ejemplo = []
    resultado = Perritos.Analisis.perros_perdidos_de_vista(avistamientos_ejemplo, 10, ~N[2026-10-26 12:00:00])

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "<html><body><h1>Modulo de Analisis de Perritos</h1><p>Resultados: #{inspect(resultado)}</p></body></html>")
  end

  match _ do
    send_resp(conn, 404, "Pagina no encontrada")
  end
end