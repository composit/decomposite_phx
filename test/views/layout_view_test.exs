defmodule Decomposite.LayoutViewTest do
  use Decomposite.ConnCase

  alias Decomposite.LayoutView

  setup do
    {:ok, discourse} = initialize_discourses(%{})

    {:ok, discourse: discourse}
  end

  test "user type is initiator", %{discourse: discourse} do
    assert LayoutView.user_type(discourse, discourse.initiator_id) == "initiator"
  end

  test "user type is replier", %{discourse: discourse} do
    assert LayoutView.user_type(discourse, discourse.replier_id) == "replier"
  end

  test "user type is commenter", %{discourse: discourse} do
    {:ok, commenter} = create_test_user(name: "commenter")
    assert LayoutView.user_type(discourse, commenter.id) == "commenter"
  end

  test "returns user name" do
    assert false
  end

  test "returns nil if unauthenticated" do
    assert false
  end
end
