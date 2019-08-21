defmodule GimmeTix.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :current_user, :integer
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :current_user])
    |> validate_required([:name, :current_user])
  end
end
