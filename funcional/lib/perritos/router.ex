defmodule Perritos.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, """
    <!DOCTYPE html>
    <html>
      <head><title>Perritos App</title></head>
      <body>
        <nav>
          <a href="/">Inicio</a> | 
          <a href="/analisis">Análisis de Perros Perdidos</a>
        </nav>
        <h1>Bienvenido a Perritos App</h1>
      </body>
    </html>
    """)
  end

  get "/analisis" do
    resultado = Perritos.Analisis.perros_perdidos_de_vista([], 10, ~N[2026-10-26 12:00:00])

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, """
    <!DOCTYPE html>
    <html>
      <head><title>Análisis - Perritos App</title></head>
      <body>
        <nav>
          <a href="/">Inicio</a> | 
          <a href="/analisis">Análisis de Perros Perdidos</a>
        </nav>
        <h1>Módulo de Análisis de Perritos</h1>
        <p>Resultados del análisis:</p>
        <pre>#{inspect(resultado)}</pre>
      </body>
    </html>
    """)
  end

  match _ do
    send_resp(conn, 404, "Página no encontrada")
  end
end