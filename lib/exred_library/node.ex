defmodule Exred.Library.Node do
  @enforce_keys [:id, :name, :module, :config]
  defstruct [:id, :name, :module, :config, :flow_id]
end