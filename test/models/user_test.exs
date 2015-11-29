require IEx

defmodule Decomposite.UserTest do
  use Decomposite.ModelCase

  alias Decomposite.User

  @valid_attrs %{password: "somepass", name: "testuser"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "name has to be unique" do
    changeset_one = User.changeset(%User{}, @valid_attrs)
    Decomposite.Repo.insert(changeset_one)

    changeset_two = User.changeset(%User{}, @valid_attrs)
    {:error, changeset} = Repo.insert(changeset_two)
    assert changeset.errors[:name] == "has already been taken"
  end
end
