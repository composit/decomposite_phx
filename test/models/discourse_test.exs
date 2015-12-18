defmodule Decomposite.DiscourseTest do
  use Decomposite.ModelCase

  alias Decomposite.Discourse

  setup do
    {:ok, discourse} = initialize_discourses(%{})

    {:ok, discourse: discourse}
  end

  test "changeset with valid attributes", %{discourse: discourse} do
    assert Enum.empty? errors_on(discourse, %{})
  end

  test "initiator can contribute when it's their turn (when the number of points is odd)", %{discourse: discourse} do
    points = discourse.points["p"] ++ ["point four", "point five"]
    assert Enum.empty? errors_on(discourse, %{points: %{"p" => points}, updater_id: discourse.initiator_id})
  end

  test "initiator can't contribute when it isn't their turn (when the number of points is even)", %{discourse: discourse} do
    points = discourse.points["p"] ++ ["point four"]
    assert {:updater_id, "does not have permissions to update this discourse"} in errors_on(discourse, %{points: %{"p" => points}, updater_id: discourse.initiator_id})
  end

  test "replier can contribute when it's their turn (when the number of points is even)", %{discourse: discourse} do
    points = discourse.points["p"] ++ ["point four"]
    assert Enum.empty? errors_on(discourse, %{points: %{"p" => points}, updater_id: discourse.replier_id})
  end

  test "replier can't contribute when it's not their turn (when the number of points is odd)", %{discourse: discourse} do
    points = discourse.points["p"] ++ ["point four", "point five"]
    assert {:updater_id, "does not have permissions to update this discourse"} in errors_on(discourse, %{points: %{"p" => points}, updater_id: discourse.replier_id})
  end

  test "unauthorized contributor can't contribute", %{discourse: discourse} do
    {_, user} = create_test_user(name: "tester1")
    assert {:updater_id, "does not have permissions to update this discourse"} in errors_on(discourse, %{points: %{"p" => ["point one"]}, updater_id: user.id})
  end

  test "logged in user can add a comment to an existing discourse", %{discourse: discourse} do
    {_, user} = create_test_user(name: "tester2")
    assert Enum.empty? errors_on(discourse, %{comments: %{"c" => ["comment one"]}, updater_id: user.id})
  end

  test "non-logged in user can't add a comment", %{discourse: discourse} do
    assert {:updater_id, "can't be blank"} in errors_on(discourse, %{updater_id: nil})
  end

  test "new discourse must match parent's point & comment & initiator & commentor" do
    {_, commenter} = create_test_user(name: "commenter")
    parent_attrs = %{
      comments: %{"c" => [[["comment one", commenter.id]]]},
    }
    {:ok, parent_discourse} = initialize_discourses(parent_attrs)
    initiator_id = parent_discourse.initiator_id
    good_attrs = valid_discourse_attrs
    |> Dict.merge %{
      parent_discourse_id: parent_discourse.id,
      parent_point_index: 0,
      parent_comment_index: 0,
      points: %{"p" => ["point one", "comment one", "new point"]},
      initiator_id: initiator_id,
      replier_id: commenter.id,
      updater_id: initiator_id
    }
    assert Enum.empty? errors_on(%Discourse{}, good_attrs)

    bad_attr = %{points: %{"p" => ["bad point", "comment one", "new point"]}}
    assert {:points, "do not match the parent point"} in errors_on(%Discourse{}, Dict.merge(good_attrs, bad_attr))

    bad_attr = %{points: %{"p" => ["point one", "bad point", "new point"]}}
    assert {:points, "do not match the parent comment"} in errors_on(%Discourse{}, Dict.merge(good_attrs, bad_attr))

    bad_attr = %{initiator_id: commenter.id} # as long as it's not the initiator, doesn't matter who
    assert {:initiator_id, "does not match the parent"} in errors_on(%Discourse{}, Dict.merge(good_attrs, bad_attr))
    
    bad_attr = %{replier_id: initiator_id} # as long as it's not the commenter, doesn't matter who
    assert {:replier_id, "does not match the parent"} in errors_on(%Discourse{}, Dict.merge(good_attrs, bad_attr))
  end
end
