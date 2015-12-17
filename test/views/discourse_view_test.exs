defmodule Decomposite.DiscourseViewTest do
  use Decomposite.ConnCase, async: false

  alias Decomposite.DiscourseView

  setup do
    {:ok, initiator} = create_test_user(name: "initiator")
    {:ok, replier} = create_test_user(name: "replier")
    {:ok, commenter} = create_test_user(name: "commenter")
    {:ok, discourse} = initialize_discourses(%{
      points: %{"p" => ["point one", "point two", "point three"]},
      comments: %{"c" => [[["comment one", "user_id", "thread_id"]], [["comment two"], ["comment two-two", commenter.id]], [["comment three"]]]},
      initiator_id: initiator.id,
      replier_id: replier.id,
      updater_id: initiator.id
    })
    discourse = Repo.preload(discourse, [:initiator, :replier])

    {:ok, discourse: discourse, initiator: initiator, replier: replier, commenter: commenter}
  end

  test "returns the sayer name", %{discourse: discourse, initiator: initiator, replier: replier} do
    assert DiscourseView.sayer_name(discourse, 0) == "initiator"
    assert DiscourseView.sayer_name(discourse, 1) == "replier"
  end

  test "finds user by id", %{replier: replier} do
    assert DiscourseView.find_user(replier.id).id == replier.id
  end

  test "displays comments for initiator points to initiator", %{discourse: discourse, initiator: initiator, replier: replier, commenter: commenter} do
    assert DiscourseView.visible_comments(discourse, 2, initiator.id) == [["comment three"]]
    assert DiscourseView.visible_comments(discourse, 2, replier.id) == []
    assert DiscourseView.visible_comments(discourse, 2, commenter.id) == []
  end

  test "displays comments for replier points to replier", %{discourse: discourse, initiator: initiator, replier: replier, commenter: commenter} do
    assert DiscourseView.visible_comments(discourse, 1, initiator.id) == []
    assert DiscourseView.visible_comments(discourse, 1, replier.id) == [["comment two"], ["comment two-two", commenter.id]]
    assert DiscourseView.visible_comments(discourse, 1, commenter.id) == [["comment two-two", commenter.id]]
  end

  test "displays comments with threads", %{discourse: discourse, replier: replier} do
    assert DiscourseView.visible_comments(discourse, 0, replier.id) == [["comment one", "user_id", "thread_id"]]
  end

  test "displays comments made by the current user", %{discourse: discourse, commenter: commenter} do
    assert DiscourseView.visible_comments(discourse, 1, commenter.id) == [["comment two-two", commenter.id]]
  end
end
