defmodule Decomposite.Repo.Migrations.AddInitiatorIdAndReplierIdToDiscourses do
  use Ecto.Migration

  def change do
    alter table(:discourses) do
      add :initiator_id, references(:users)
      add :replier_id, references(:users)
    end

    create index(:discourses, [:initiator_id])
    create index(:discourses, [:replier_id])
  end
end
