defmodule Decomposite.Repo.Migrations.CreateDiscourse do
  use Ecto.Migration

  def change do
    create table(:discourses) do
      add :things_said, :map
      add :parent_thing_said_index, :integer
      add :parent_discourse_id, references(:discourses)

      timestamps
    end
    create index(:discourses, [:parent_discourse_id])

  end
end
