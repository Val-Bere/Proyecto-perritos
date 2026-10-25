defmodule Perritos.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Perritos.Router.init([])

  test "GET /f/salud responde ok" do
    conn = conn(:get, "/f/salud") |> Perritos.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "ok"
  end

  test "ruta desconocida responde 404" do
    conn = conn(:get, "/f/no-existe") |> Perritos.Router.call(@opts)

    assert conn.status == 404
  end
end
