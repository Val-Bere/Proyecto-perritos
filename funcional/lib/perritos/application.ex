defmodule Perritos.Application do
  @moduledoc "Arranca el servidor HTTP del servicio Elixir."
  use Application

  def start(_tipo, _args) do
    hijos = [
      {Bandit, plug: Perritos.Router, port: 4000}
    ]

    Supervisor.start_link(hijos, strategy: :one_for_one, name: Perritos.Supervisor)
  end
end
