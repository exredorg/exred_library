defmodule Exred.Library.Node do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exred.Library.Node

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  schema "nodes" do
    field(:name, :string)
    field(:category, :string)
    field(:config, :map)
    field(:info, :string)
    field(:module, :string)
    field(:is_prototype, :boolean)
    field(:x, :integer)
    field(:y, :integer)
    field(:ui_attributes, :map)

    belongs_to(:flow, Exred.Library.Flow, type: Ecto.UUID)
    has_many(:in_conns, Exred.Library.Connection, foreign_key: :target_id)
    has_many(:out_conns, Exred.Library.Connection, foreign_key: :source_id)

    timestamps()
  end

  @doc false
  def changeset(%Node{} = node, attrs) do
    node
    |> cast(attrs, [
      :id,
      :flow_id,
      :name,
      :module,
      :config,
      :info,
      :is_prototype,
      :category,
      :x,
      :y,
      :ui_attributes
    ])
    |> validate_required([:id, :name, :module, :config, :info, :is_prototype, :category])
  end
end