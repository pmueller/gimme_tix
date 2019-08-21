defmodule GimmeTix.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uuid, :string
      add :pos_in_queue, :integer
      add :event_id, references(:events, on_delete: :nothing)

      timestamps()
    end

    create index(:users, [:event_id])
  end
end
