defmodule Decomposite.Repo.Migrations.AddParentCommentIndexToDiscourse do
  use Ecto.Migration

  def change do
    alter table(:discourses) do
      add :parent_comment_index, :integer
    end
  end
end
