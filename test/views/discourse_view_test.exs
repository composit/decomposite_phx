defmodule Decomposite.DiscourseViewTest do
  use Decomposite.ConnCase, async: false

  alias Decomposite.DiscourseView

  setup do
    {:ok, commenter} = create_test_user(name: "commenter")
    {:ok, discourse} = initialize_discourses(%{
      comments: %{"c" => [[["comment one", "user_id", "thread_id"]], [["comment two"], ["comment two-two", commenter.id]], [["comment three"]]]},
    })
    discourse = Repo.preload(discourse, [:initiator, :replier])

    {:ok, discourse: discourse, commenter: commenter}
  end

  test "returns the sayer name", %{discourse: discourse} do
    assert DiscourseView.sayer_name(discourse, 0) == discourse.initiator.name
    assert DiscourseView.sayer_name(discourse, 1) == discourse.replier.name
  end

  test "finds user by id", %{discourse: discourse} do
    assert DiscourseView.find_user(discourse.replier_id).id == discourse.replier_id
  end

  test "displays comments for initiator points to initiator", %{discourse: discourse, commenter: commenter} do
    assert DiscourseView.visible_comments(discourse, 2, discourse.initiator_id) == [["comment three"]]
    assert DiscourseView.visible_comments(discourse, 2, discourse.replier_id) == []
    assert DiscourseView.visible_comments(discourse, 2, commenter.id) == []
  end

  test "displays comments for replier points to replier", %{discourse: discourse, commenter: commenter} do
    assert DiscourseView.visible_comments(discourse, 1, discourse.initiator_id) == []
    assert DiscourseView.visible_comments(discourse, 1, discourse.replier_id) == [["comment two"], ["comment two-two", commenter.id]]
    assert DiscourseView.visible_comments(discourse, 1, commenter.id) == [["comment two-two", commenter.id]]
  end

  test "displays comments with threads", %{discourse: discourse} do
    assert DiscourseView.visible_comments(discourse, 0, discourse.replier_id) == [["comment one", "user_id", "thread_id"]]
  end

  test "displays comments made by the current user", %{discourse: discourse, commenter: commenter} do
    assert DiscourseView.visible_comments(discourse, 1, commenter.id) == [["comment two-two", commenter.id]]
  end

  test "determines if the current point was authored by the current_user", %{discourse: discourse} do
    assert DiscourseView.belongs_to_user(discourse, 1, discourse.replier_id)
    refute DiscourseView.belongs_to_user(discourse, 1, discourse.initiator_id)
  end
end
