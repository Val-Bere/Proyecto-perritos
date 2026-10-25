defmodule Perritos.Application do
  @moduledoc "SHELL: arranca el servidor web (Bandit) con el router."
  use Application

  @impl true
  def start(_type, _args) do
    puerto = String.to_integer(System.get_env("PORT") || "4000")

    children = [
      {Bandit, plug: Perritos.Router, scheme: :http, port: puerto, ip: {0, 0, 0, 0}}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Perritos.Supervisor)
  end
end
