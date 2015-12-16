defmodule Decomposite.DiscourseTest do
  use Decomposite.ModelCase

  alias Decomposite.Discourse

  test "changeset with valid attributes" do
    assert Enum.empty? errors_on(%Discourse{}, valid_discourse_attrs)
  end

  test "initiator can contribute when it's their turn (when the number of points is odd)" do
    assert Enum.empty? errors_on(%Discourse{}, Dict.merge(valid_discourse_attrs, %{points: %{"p" => ["point one"]}, updater_id: 123}))
  end

  test "initiator can't contribute when it isn't their turn (when the number of points is even)" do
    assert {:updater_id, "does not have permissions to update this discourse"} in errors_on(%Discourse{}, %{points: %{"p" => ["point one", "point two"]}, updater_id: 123})
  end

  test "responder can contribute when it's their turn (when the number of points is even)" do
    assert Enum.empty? errors_on(%Discourse{}, Dict.merge(valid_discourse_attrs, %{points: %{"p" => ["point one", "point two"]}, updater_id: 456}))
  end

  test "responder can't contribute when it's not their turn (when the number of points is odd)" do
    assert {:updater_id, "does not have permissions to update this discourse"} in errors_on(%Discourse{}, %{points: %{"p" => ["point one"]}, updater_id: 456})
  end

  test "unauthorized contributor can't contribute" do
    assert {:updater_id, "does not have permissions to update this discourse"} in errors_on(%Discourse{}, %{points: %{"p" => ["point one"]}, updater_id: 789})
  end

  test "logged in user can add a comment to an existing discourse" do
    attrs = valid_discourse_attrs
    |> Dict.delete(:parent_discourse_id)
    |> Dict.delete(:initiator_id)
    |> Dict.delete(:replier_id)
    |> Dict.delete(:updater_id)
    {:ok, initial_discourse} = initialize_discourses(attrs)
    assert Enum.empty? errors_on(initial_discourse, Dict.merge(valid_discourse_attrs, %{comments: %{"c" => ["comment one"]}, updater_id: 987}))
  end

  test "non-logged in user can't add a comment" do
    assert {:updater_id, "can't be blank"} in errors_on(%Discourse{}, %{updater_id: nil})
  end
end
