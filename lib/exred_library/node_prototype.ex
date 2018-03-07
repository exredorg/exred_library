defmodule Exred.Library.NodePrototype do
  @moduledoc """
  Behaviour to define node prototypes
  """

  @name "NodePrototype"
  @category "Undefined"
  @config %{}
  @info "Node prototype info"

  @doc """
  This gets called when the module is loaded.
  It should set up set up services that the node needs
  (autheticate with an API or set up database access)
  """
  @callback prepare() :: list
  @callback node_init(state :: term) :: term
  @callback handle_msg(msg :: term, node_data :: term) :: {term, term}
  @callback fire(state :: term) :: term

  defmacro __using__(_opts) do
    quote do
      IO.inspect "Compiling node prototype: #{__MODULE__}"
      
      alias Exred.Scheduler.EventChannelClient

      @behaviour Exred.Library.NodePrototype

      def attributes do
        %{
          name: @name,
          category: @category,
          info: @info,
          config: @config
        }
      end

      def prepare(), do: [prepare: :done]
      def node_init(state), do: state
      def handle_msg(msg, state), do: {msg, state}
      def fire(state) do
        IO.puts "#{inspect self()} firing: #{inspect state.node_id}"
        state
      end

      defoverridable prepare: 0, node_init: 1, handle_msg: 2, fire: 1


      use GenServer

      # API
      def start_link([node_id, node_config]) do
        GenServer.start_link(__MODULE__, [node_id, node_config], name: node_id)
      end

      def get_state(pid) do
        GenServer.call(pid, :get_state)
      end

      def set_out_nodes(pid, out_nodes) do
        GenServer.call(pid, {:set_out_nodes, out_nodes})
      end
      
      def add_out_node(pid, new_out) do
        GenServer.call(pid, {:add_out_node, new_out})
      end

      def get_name, do: @name
      def get_category, do: @category
      def get_default_config, do: @config

      # Callbacks

      @impl true
      def init([node_id, node_config]) do
        state = %{node_id: node_id, config: node_config, node_data: %{}, out_nodes: []}
        |> node_init()

        {:ok, state}
      end


      @impl true
      def handle_call(:get_state, _from, state) do
        {:reply, state, state}
      end

      def handle_call({:set_out_nodes, out_nodes}, _from, state) do
        {:reply, :ok, state |> Map.put(:out_nodes, out_nodes)}
      end
      
      def handle_call({:add_out_node, new_out}, _from, %{out_nodes: out_nodes} = state) do
        {:reply, :ok, %{state | out_nodes: [new_out | out_nodes]}}
      end

      def handle_call(:fire, _from, state) do
        {:reply, :ok, fire(state)}
      end


      @impl true
      def handle_info(msg, state) do
        {msg_out, new_state} = handle_msg(msg, state)
        Enum.each state.out_nodes, & send(&1, msg_out)
        {:noreply, new_state}
      end
      
      @impl true
      def terminate(reason, state) do 
        event = "notification"
        debug_data = %{exit_reason: Exception.format_exit(reason)}
        event_msg = %{node_id: state.node_id, node_name: @name, debug_data: debug_data}
        EventChannelClient.broadcast event, event_msg
        :return_value_ignored
      end
    end
  end

end
