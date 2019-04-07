defmodule Exred.Library.DbProxy do
  @moduledoc """
  Maintaines db connection and proxies updates and queries
  """

  require Logger
  use GenServer
  alias Exred.Library.SqliteRepo

  # API

  def start_link(args) do
    Logger.info("starting #{__MODULE__}")
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def query(query, params \\ []) do
    GenServer.call(__MODULE__, {:query, query, params})
  end

  # Callbacks

  def init(_args) do
    {:ok, []}
  end

  def handle_call({:query, query, _params}, _from, state) do
    res = SqliteRepo.all(query)
    {:reply, {:ok, res}, state}

    # case Postgrex.query(pid, query, params) do
    #   {:ok, res} ->
    #     {:reply, {:ok, res}, pid}

    #   {:error, err} ->
    #     err_short = Map.take(err.postgres, [:code, :table, :detail])
    #     Logger.warn("#{inspect(err_short)}")
    #     {:reply, {:error, err}, pid}
    # end
  end
end
