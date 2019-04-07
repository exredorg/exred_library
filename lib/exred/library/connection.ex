defmodule Exred.Library.Connection do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exred.Library.Connection

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  schema "connections" do
    field(:config, :map)
    field(:source_anchor_type, :string)
    field(:target_anchor_type, :string)

    belongs_to(:source, Exred.Library.Node, type: Ecto.UUID, foreign_key: :source_id)
    belongs_to(:target, Exred.Library.Node, type: Ecto.UUID, foreign_key: :target_id)
    belongs_to(:flow, Exred.Library.Flow, type: Ecto.UUID)

    timestamps()
  end

  @doc false
  def changeset(%Connection{} = connection, attrs) do
    connection
    |> cast(attrs, [
      :id,
      :source_id,
      :target_id,
      :flow_id,
      :config,
      :source_anchor_type,
      :target_anchor_type
    ])
    |> validate_required([:id, :source_id, :target_id, :flow_id, :config])
  end
end
