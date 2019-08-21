defmodule GimmeTix.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :current_user, :integer

      timestamps()
    end

  end
end
