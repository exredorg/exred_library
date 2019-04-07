defmodule Exred.Library.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Exred.Library.SqliteRepo, []),
      {Exred.Library.DbProxy, []},
      {Exred.Library.Registrar, []}
    ]

    opts = [strategy: :one_for_one, name: Exred.Library.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
