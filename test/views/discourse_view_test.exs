defmodule Decomposite.DiscourseViewTest do
  use Decomposite.ConnCase, async: false

  alias Decomposite.DiscourseView

  setup do
    {:ok, initiator} = create_test_user(name: "initiator")
    {:ok, replier} = create_test_user(name: "replier")
    {:ok, discourse} = initialize_discourses(%{
      points: %{"p" => ["point one", "point two", "point three"]},
      comments: %{"c" => [[["comment one"]], [["comment two"]], [["comment three"]]]},
      initiator_id: initiator.id,
      replier_id: replier.id,
      updater_id: initiator.id
    })
    discourse = Repo.preload(discourse, [:initiator, :replier])

    {:ok, discourse: discourse, initiator: initiator, replier: replier}
  end

  test "returns the sayer name", %{discourse: discourse, initiator: initiator, replier: replier} do
    assert DiscourseView.sayer_name(discourse, 0) == "initiator"
    assert DiscourseView.sayer_name(discourse, 1) == "replier"
  end

  test "finds comments by point index", %{discourse: discourse} do
    assert DiscourseView.comments_by_point_index(discourse.comments, 1) == [["comment two"]]
  end

  test "finds user by id", %{replier: replier} do
    assert DiscourseView.find_user(replier.id).id == replier.id
  end
end
