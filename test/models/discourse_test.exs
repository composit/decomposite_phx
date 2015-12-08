defmodule Decomposite.DiscourseTest do
  use Decomposite.ModelCase

  alias Decomposite.Discourse

  @valid_attrs %{parent_discourse_id: "abc123", parent_thing_said_index: 42, things_said: %{"t" => []}, initiator_id: 123, replier_id: 456, updater_id: 456}
  @invalid_attrs %{things_said: %{"t" => []}}

  test "changeset with valid attributes" do
    changeset = Discourse.changeset(%Discourse{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Discourse.changeset(%Discourse{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "unauthorized contributor can't contribute" do
    changeset = Discourse.changeset(%Discourse{}, Dict.merge(@valid_attrs, %{updater_id: 789}))
    refute changeset.valid?
  end
end
