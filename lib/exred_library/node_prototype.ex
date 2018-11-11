defmodule Exred.Library.NodePrototype do
  @moduledoc """
  ### Basic Example
  ```elixir
  defmodule Exred.Node.HelloWorld do
    @moduledoc \"""
    Sends "Hello World" or any other configured greeting as payload
    when it receives a message.

    **Incoming message format**
    Anything / ignored

    **Outgoing message format**
    msg = %{
      payload :: string
    }
    \"""

    @name "Greeter"
    @category "output"
    @info @moduledoc
    @config %{
      name: %{
        info: "Visible node name",
        value: @name,
        type: "string",
        attrs: %{max: 20}
      },
      greeting: %{
        info: "Greeting to be sent",
        value: "Hello World",
        type: "string",
        attrs: %{max: 40}
      }
    }
    @ui_attributes %{
      left_icon: "face"
    }

    use Exred.Library.NodePrototype

    @impl true
    def handle_msg(msg, state) do
      out = Map.put(msg, :payload, state.config.greeting.value)
      {out, state}
    end
  end
  ```

  ### Module Attributes

  __@name :: string__
  Name of the node. This will be the visible name in the UI.

  __@category :: string__
  Name of the category the node is in. Categories are the panel headers in the node selector on the left side of the UI.
  The name of the category also determines the color of the node given in `exred/ui/app/styles/app.scss` (see .exred-category-function, etc. CSS classes)

  __@info :: string__
  Description of the node. This is displayed in the Info tab in the UI.
  It is usually a longer multi-line string and it is interpreted as markdown text.

  __@config :: map__
  This is a map of configurable values for the node.
  These are displayed in the Config tab in the UI and the values are accessible in the `state` argument in the node.

  There are different types of config entries represented by different widgets in the UI.
  Each type has its unique attributes.
  Node types match the UI components in `exred/ui/app/templates/components/x-config-tab/`

  Keys in the map are:
  - type: type of the config item
  - info: short descritpion of the config item (will be displayed as a tooltip)
  - value: default value for the config item
  - attrs :: map : map of attributes based on the type


  #### type: "string"
  ```elixir
  config_item: %{
    type: "string",
    info: "Short description",
    value: "default value",
    attrs: %{max: 50}
  }
  ```
  Attributes:
  - max : maximum length of the string

  #### type: "number"
  ```elixir
  config_item: %{
    type: "number",
    info: "Short description",
    value: 22,
    attrs: %{min: 10, max: 50}
  }
  ```
  Attributes:
  - max : maximum length of the string

  #### type: "select"
  ```elixir
  config_item: %{
    type: "select",
    info: "Short description",
    value: "GET",
    attrs: %{options: ["GET", "POST", "PATCH"]}
  }
  ```
  Attributes:
  - options : list of options for the selector

  #### type: "list-singleselect"
  ```elixir
  config_item: %{
    info: "Short description",
    type: "list-singleselect",
    value: [],
    attrs: %{items: ["Display 1", "Display 2"]}
  },
  ```
  Attributes:
  - items : list of items to select from

  #### type: "list-multiselect"
  ```elixir
  config_item: %{
    type: "list-multiselect",
    info: "Short description",
    value: [],
    attrs: %{items: ["channel1", "channel2", "channel3"]}
  }
  ```
  Attributes:
  - items : list of items to select from

  #### type: "codeblock"
  ```elixir
  config_item: %{
    type: "codeblock",
    info: "Short description",
    value: "default value"
  }
  ```
  No attributes


  #### Example (@config map):
  ```elixir
  @config %{
    name: %{
      info: "Visible node name",
      value: "GPIO In",
      type: "string",
      attrs: %{max: 20}
    },
    pin_number: %{
      info: "GPIO pin number that the node will read",
      value: 0,
      type: "number",
      attrs: %{min: 0}
    },
    mode: %{
      info: "read_on_message or monitor",
      type: "list-singleselect",
      value: nil,
      attrs: %{items: ["read_on_message", "monitor"]}
    },
    monitored_transition: %{
      info: "send message in rising and/or falling edge",
      type: "list-multiselect",
      value: [],
      attrs: %{items: ["rising", "falling"]}
    }
  }
  ```

  __@ui_attributes__
  Additional UI attributes for the node.
  ```elixir
  @ui_attributes %{
    fire_button: false,
    left_icon: nil,
    right_icon: "send",
    config_order: [:name,:pin_number,:mode]
  }
  ```
  - fire_button :: boolean :  clickable button on the node in the UI. Sends a fire message to the node's gen_server
  - left_icon :: string, right_icon :: string : material design icon name (see [Material Design Icons](https://material.io/tools/icons/?style=baseline))
  - config_order :: list : list of the config items in the order we want to display them in the UI

  ### Module Callbacks

  #### node_init(state)
  ```elixir
  node_init(state :: map) :: map | {map, integer}
  ```
  This is called as the last step of the node's init function.
  Needs to return a new state or a {state, timeout} tuple.
  (see GenServer documentation)

  #### handle_msg(msg, state)
  ```elixir
  handle_msg(msg :: map, state :: map) :: {map | nil, map}
  ```
  Handles incoming messages sent to the node from another node.
  Returns the outgoing message and a state.
  If the outgoing message is `nil` then no message will be sent from the node.

  #### fire(state)
  ```elixir
  fire(state :: map) :: map`
  ```
  Called when the fire button is pressed on the node in the UI.
  Needs to return the updated state.

  If the fire action needs to send an outgoing message from the node that can be done with the standard `send/2` function.
  `state.out_nodes` is a list of node PIDs that are connected to this node with outgoing edges.


  Example:
  ```elixir
  def fire(state) do
    Enum.each state.out_nodes, & send(&1, %{payload: "hello"})
    state
  end
  ```

  ### Complete Node Example
  [Link to node in github]()
  """

  @name "NodePrototype"
  @category "Undefined"
  @config %{}
  @info @moduledoc

  # icon names are the standard material design icons
  @ui_attributes %{fire_button: false, left_icon: "thumb_up", right_icon: nil}

  # TODO: prepare/0 is not used, get rid of it?
  @doc """
  This gets called when the module is loaded.
  It should set up set up services that the node needs
  (autheticate with an API or set up database access)
  """
  # @callback prepare() :: list

  @doc """
  Initialize node.
  This is called as the last step of the node's init function.
  Needs to return a new state or a {state, timeout} tuple.
  (see GenServer documentation)
  """
  @callback node_init(state :: map) :: map | {map, integer}
  @callback handle_msg(msg :: map, state :: map) :: {map | nil, map}
  @callback fire(state :: map) :: map

  defmacro __using__(_opts) do
    quote do
      IO.inspect("Compiling node prototype: #{__MODULE__}")

      require Logger

      @behaviour Exred.Library.NodePrototype

      def attributes do
        config_order =
          if Keyword.keyword?(@config) do
            Keyword.keys(@config)
          else
            Map.keys(@config)
          end

        %{
          name: @name,
          category: @category,
          info: @info,
          config: Enum.into(@config, %{}),
          ui_attributes: Enum.into(@ui_attributes, %{config_order: config_order})
        }
      end

      def prepare(), do: [prepare: :done]
      def node_init(state), do: state
      def handle_msg(msg, state), do: {msg, state}

      def fire(state) do
        IO.puts("#{inspect(self())} firing: #{inspect(state.node_id)}")
        state
      end

      defoverridable prepare: 0, node_init: 1, handle_msg: 2, fire: 1

      use GenServer

      # API
      def start_link([node_id, node_config, send_event]) do
        Logger.debug("node: #{node_id} #{get_in(node_config, [:name, :value])} START_LINK")
        GenServer.start_link(__MODULE__, [node_id, node_config, send_event], name: node_id)
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
      def init([node_id, node_config, send_event]) do
        Logger.debug("node: #{node_id} #{get_in(node_config, [:name, :value])} INIT")

        # trap exits to make sure terminate/2 gets called by GenServer
        Process.flag(:trap_exit, true)

        default_state = %{
          node_id: node_id,
          config: node_config,
          node_data: %{},
          out_nodes: [],
          send_event: send_event
        }

        case node_init(default_state) do
          {state, timeout} ->
            Logger.debug(
              "node: #{node_id} #{get_in(node_config, [:name, :value])} INIT timeout: #{
                inspect(timeout)
              }"
            )

            {:ok, state, timeout}

          state ->
            Logger.debug(
              "node: #{node_id} #{get_in(node_config, [:name, :value])} INIT no timeout"
            )

            {:ok, state}
        end
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
        Logger.debug(
          "node: #{state.node_id} #{get_in(state.config, [:name, :value])} GOT: #{inspect(msg)}"
        )

        {msg_out, new_state} = handle_msg(msg, state)

        if msg_out != nil do
          Enum.each(state.out_nodes, &send(&1, msg_out))
        end

        {:noreply, new_state}
      end

      def handle_info(msg, state) do
        Logger.debug(
          "UNHANDLED msg: #{state.node_id} #{get_in(state.config, [:name, :value])} GOT: #{
            inspect(msg)
          }"
        )

        {:noreply, state}
      end

      @impl true
      def terminate(reason, state) do
        event = "notification"
        debug_data = %{exit_reason: Exception.format_exit(reason)}
        payload = %{node_id: state.node_id, node_name: @name, debug_data: debug_data}

        Logger.error(
          "node: #{state.node_id} #{get_in(state.config, [:name, :value])} TERMINATING due to: #{
            inspect(debug_data)
          }"
        )

        # EventChannel.send(event, payload)
        state.send_event(event, payload)
        :return_value_ignored
      end
    end
  end
end
