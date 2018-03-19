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
    # use db connection from the Phoenix app if it's loaded
    exred_db = Application.get_env :exred, Exred.Repo
    db_conn = if exred_db do
      exred_db
    else
      db_conn = Application.get_env :exred_library, :psql_conn
    end
    hostname = Keyword.get db_conn, :hostname
    username = Keyword.get db_conn, :username
    password = Keyword.get db_conn, :password
    database = Keyword.get db_conn, :database
    
    Postgrex.start_link hostname: hostname, username: username, password: password, database: database, types: Exred.Library.PostgrexTypes
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
