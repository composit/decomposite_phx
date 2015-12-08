defmodule Decomposite.Repo.Migrations.RenameThingsSaidToPoints do
  use Ecto.Migration

  def change do
    rename table(:discourses), :things_said, to: :points
    rename table(:discourses), :parent_thing_said_index, to: :parent_point_index
  end
end
