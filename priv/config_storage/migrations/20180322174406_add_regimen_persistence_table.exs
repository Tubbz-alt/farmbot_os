defmodule Farmbot.Repo.Migrations.AddRegimenPersistenceTable do
  use Ecto.Migration

  def change do
    create table(:persistent_regimens) do
      add :regimen_id, :integer
      add :time, :utc_datetime
      timestamps()
    end

    create unique_index(:persistent_regimens, [:regimen_id])
  end
end
