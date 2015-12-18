defmodule Decomposite.DiscourseFactoryTest do
  use Decomposite.ModelCase
  alias Decomposite.DiscourseFactory

  setup do
    {:ok, commenter} = create_test_user
    {:ok, parent_discourse} = initialize_discourses(%{
      comments: %{"c" => [[["comment one"]], [["comment two"], ["comment three", commenter.id]]]}
    })
    discourse = DiscourseFactory.build_from_parent(parent_discourse.id, "1", "1", parent_discourse.initiator_id, "new point")
    {:ok, discourse: discourse, parent_discourse: parent_discourse, commenter: commenter}
  end

  test "assigns the parent discourse id", %{discourse: discourse, parent_discourse: parent_discourse} do
    assert discourse.parent_discourse.id == parent_discourse.id
  end

  test "assigns the initiator id", %{discourse: discourse, parent_discourse: parent_discourse} do
    assert discourse.initiator.id == parent_discourse.initiator_id
  end

  test "assigns the replier id", %{discourse: discourse, commenter: commenter} do
    assert discourse.replier.id == commenter.id
  end

  test "assigns the parent_point_index", %{discourse: discourse} do
    assert discourse.parent_point_index == 1
  end

  test "assigns the parent_comment_index", %{discourse: discourse} do
    assert discourse.parent_comment_index == 1
  end

  test "assigns the points", %{discourse: discourse} do
    assert discourse.points["p"] == ["point two", "comment three", "new point"]
  end

  test "assigns empty comments", %{discourse: discourse} do
    assert discourse.comments["c"] == []
  end
end
