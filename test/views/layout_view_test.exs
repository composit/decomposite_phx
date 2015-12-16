defmodule Decomposite.LayoutViewTest do
  use Decomposite.ConnCase

  alias Decomposite.LayoutView

  setup do
    {:ok, initiator} = create_test_user(name: "initiator")
    {:ok, replier} = create_test_user(name: "replier")

    {:ok, discourse} = initialize_discourses(%{
      initiator_id: initiator.id,
      replier_id: replier.id,
      updater_id: replier.id
    })

    {:ok, discourse: discourse, initiator: initiator, replier: replier}
  end

  test "user type is initiator", %{discourse: discourse, initiator: initiator} do
    assert LayoutView.user_type(discourse, initiator.id) == "initiator"
  end

  test "user type is replier", %{discourse: discourse, replier: replier} do
    assert LayoutView.user_type(discourse, replier.id) == "replier"
  end

  test "user type is commenter", %{discourse: discourse} do
    {:ok, commenter} = create_test_user(name: "commenter")
    assert LayoutView.user_type(discourse, commenter.id) == "commenter"
  end
end
