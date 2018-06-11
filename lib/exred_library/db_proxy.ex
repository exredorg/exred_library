defmodule Exred.Library.DbProxy do
  @moduledoc """
  Maintaines db connection and proxies updates and queries
  """

  require Logger
  use GenServer

  # API

  def start_link(args) do
    Logger.info "starting #{__MODULE__}"
    GenServer.start_link __MODULE__, args, name: __MODULE__
  end

  def query(query, params \\ []) do
    GenServer.call __MODULE__, {:query, query, params}
  end

  # Callbacks

  def init(_args) do
    psql_conn = Application.get_env :exred_library, :psql_conn
    hostname = Keyword.get psql_conn, :hostname
    username = Keyword.get psql_conn, :username
    password = Keyword.get psql_conn, :password
    database = Keyword.get psql_conn, :database
    port     = Keyword.get psql_conn, :port
    
    Postgrex.start_link hostname: hostname, port: port, username: username, password: password, database: database, types: Exred.Library.PostgrexTypes
  end

  def handle_call({:query, query, params}, _from, pid) do
    case Postgrex.query(pid, query, params) do
      {:ok, res} ->
        {:reply, {:ok, res}, pid}
      {:error, err} ->
        err_short = Map.take(err.postgres, [:code, :table, :detail])
        Logger.warn "#{inspect err_short}"
        {:reply, {:error, err}, pid}
    end
  end

end
