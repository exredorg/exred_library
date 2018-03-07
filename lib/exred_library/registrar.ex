defmodule Exred.Library.Registrar do
  @moduledoc """
  Tries to register nodes
  """
  require Logger
  alias Exred.Library.DbProxy

  use GenServer

  # API

  def start_link(args) do
    Logger.info "starting #{__MODULE__}"
    GenServer.start_link __MODULE__, args, name: __MODULE__
  end

  # Callbacks

  def init(_args) do
    {:ok, %{}, 2000}
  end

  def handle_info(:timeout, state) do
    # match on any application that starts with exred
    app_name_match = fn(app_name) ->
      case Atom.to_string(app_name) do
        "exred" <> _ -> true
        _ -> false
      end
    end

    # match on split module names that are probably exred nodes
    module_name_match = fn
        (["Exred", "Node", _]) -> true
        (["ExredNode", _]) -> true
        (_) -> false
    end

    node_prototype_modules = Application.loaded_applications
    |> Enum.map(& elem(&1,0) )
    |> Enum.filter( app_name_match )
    |> Enum.flat_map(& :application.get_key(&1, :modules) |> elem(1))
    |> Enum.map( &Module.split/1 )
    |> Enum.filter( module_name_match )
    |> Enum.map( &Module.safe_concat/1 )

    Enum.each node_prototype_modules, fn(module_name)->
      Logger.info( "Registering #{module_name}")
      register module_name, module_name.attributes
    end

    {:noreply, state}
  end



  def register(module_name, node_attributes) do
    # Logger.info "Register called with: #{inspect node_attributes}"

    id = UUID.uuid4() |> UUID.string_to_binary!
    timestamp = DateTime.utc_now() |> DateTime.to_naive

    query_statement = "insert into nodes(id, type, name, module, category, info, config, is_prototype, inserted_at, updated_at) values($1, 'node', $2, $3, $4, $5, $6, true, $7, $8)"
    query_params = [id, node_attributes.name, Atom.to_string(module_name), node_attributes.category, node_attributes.info, node_attributes.config, timestamp, timestamp]

    case DbProxy.query(query_statement, query_params) do
      {:ok, _} -> :ok
      {:error, err} ->
        if err.postgres.code == :unique_violation do
          :already_registered
        else
          :error
        end
    end
  end

end
