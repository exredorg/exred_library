defmodule Exred.Library do
  @moduledoc """
  Library application for Exred. Handles storage and access of flows.
  """
  import Ecto.Query, only: [from: 2]

  alias Exred.Library.DbProxy
  alias Exred.Library.Utils
  alias Exred.Library.Node
  alias Exred.Library.Connection
  alias Exred.Library.SqliteRepo

  @doc """
  Get all node instances from the database
  """
  def old_get_all_nodes do
    query_stm =
      "select id, name, category, module, config, flow_id from nodes where not is_prototype;"

    {:ok, result} = DbProxy.query(query_stm, [])

    # convert result from db to node struct
    Enum.map(result.rows, fn [id, name, category, module, config, flow_id] ->
      node_id = id |> UUID.binary_to_string!() |> String.to_atom()
      node_module = String.to_existing_atom(module)
      node_config = Utils.convert_to_atom_map(config)
      flow_id = flow_id |> UUID.binary_to_string!() |> String.to_atom()

      %Node{
        id: node_id,
        name: name,
        category: category,
        module: node_module,
        config: node_config,
        flow_id: flow_id
      }
    end)
  end

  def get_all_nodes do
    query =
      from(Node,
        where: [is_prototype: false],
        select: [:id, :name, :category, :module, :config, :flow_id]
      )

    SqliteRepo.all(query)
  end

  def get_all_connections do
    query =
      from(Connection,
        select: [:id, :source_id, :target_id, :flow_id]
      )

    SqliteRepo.all(query)
  end

  def old_get_all_connections do
    query_stm = "select id, source_id, target_id, flow_id from connections;"
    {:ok, result} = DbProxy.query(query_stm, [])

    # convert result from db to node struct
    Enum.map(result.rows, fn [id, source_id, target_id, flow_id] ->
      conn_id = id |> UUID.binary_to_string!() |> String.to_atom()
      source_id = source_id |> UUID.binary_to_string!() |> String.to_atom()
      target_id = target_id |> UUID.binary_to_string!() |> String.to_atom()
      flow_id = flow_id |> UUID.binary_to_string!() |> String.to_atom()

      %Connection{
        id: conn_id,
        source_id: source_id,
        target_id: target_id,
        flow_id: flow_id
      }
    end)
  end

  def start_nodes do
    nodes = get_all_nodes()

    Enum.each(nodes, fn node ->
      instance = node.module.create_instance(node.id, node.config)
      IO.inspect(instance, label: node.name)
    end)
  end
end
