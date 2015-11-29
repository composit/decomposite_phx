defmodule Decomposite.Repo.Migrations.MakeUserNameUnique do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:name])
  end
end
