defmodule Exred.Library.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Exred.Library.DbProxy, []},
      {Exred.Library.Registrar, []}
      # {Postgrex, [hostname: "localhost", database: "exred_dev"]}
      # Starts a worker by calling: Exred.Library.Worker.start_link(arg)
      # {Exred.Library.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exred.Library.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
