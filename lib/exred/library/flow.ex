defmodule Exred.Library.Flow do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exred.Library.Flow

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  schema "flows" do
    field(:type, :string)

    field(:name, :string)
    field(:info, :string)
    field(:config, :map)

    belongs_to(:service, Exred.Library.Service, type: Ecto.UUID)

    has_many(:nodes, Exred.Library.Node)
    has_many(:connections, Exred.Library.Connection)

    timestamps()
  end

  @doc false
  def changeset(%Flow{} = flow, attrs) do
    flow
    |> cast(attrs, [:id, :service_id, :name, :type, :info, :config])
    |> validate_required([:id, :service_id, :name, :info])
  end
end
