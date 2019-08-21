defmodule GimmeTix.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :pos_in_queue, :integer
    field :uuid, :string
    field :event_id, :id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:uuid, :pos_in_queue, :event_id])
    |> validate_required([:uuid, :pos_in_queue, :event_id])
  end
end
