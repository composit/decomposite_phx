defmodule Decomposite.Repo.Migrations.CreateDiscourse do
  use Ecto.Migration

  def change do
    create table(:discourses, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :things_said, :map
      add :parent_thing_said_index, :integer
      add :parent_discourse_id, :uuid

      timestamps
    end
    create index(:discourses, [:parent_discourse_id])

  end
end
