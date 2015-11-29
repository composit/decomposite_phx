defmodule Decomposite.DiscourseTest do
  use Decomposite.ModelCase

  alias Decomposite.Discourse

  @valid_attrs %{parent_thing_said_index: 42, things_said: %{}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Discourse.changeset(%Discourse{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Discourse.changeset(%Discourse{}, @invalid_attrs)
    refute changeset.valid?
  end
end
