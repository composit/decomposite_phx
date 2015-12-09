defmodule Decomposite.Repo.Migrations.AddCommentsToDiscourses do
  use Ecto.Migration

  def change do
    alter table(:discourses) do
      add :comments, :map
    end
  end
end
