defmodule Decomposite.DiscourseChannelTest do
  use Decomposite.ChannelCase

  alias Decomposite.DiscourseChannel
  alias Decomposite.Discourse

  setup do
    {:ok, commenter} = create_test_user

    {:ok, discourse} = initialize_discourses(%{
      comments: %{"c" => [[["comment one", commenter.id]]]},
    })

    {:ok, _, socket} =
      Phoenix.Socket.assign(socket, :user_id, discourse.initiator_id)
      |> subscribe_and_join(DiscourseChannel, "discourses:" <> discourse.id)

    {:ok, socket: socket, discourse: discourse, commenter: commenter}
  end

  test "new_discourse creates a new discourse", %{socket: socket, discourse: discourse} do
    number_of_discourses = Enum.count(Repo.all(Discourse))
    ref = push socket, "new_discourse", %{"parent_discourse_id" => discourse.id, "parent_point_index" => "0", "parent_comment_index" => "0", "body" => "new discourse!"}
    assert_reply ref, :ok, %{}
    assert Enum.count(Repo.all(Discourse)) == number_of_discourses + 1
  end

  test "new_discourse updates the child_discourse_id in the comments", %{socket: socket, discourse: discourse} do
    ref = push socket, "new_discourse", %{"parent_discourse_id" => discourse.id, "parent_point_index" => "0", "parent_comment_index" => "0", "body" => "new discourse!"}
    assert_reply ref, :ok, %{}
    updated_discourse = Repo.get!(Discourse, discourse.id)
    child_discourse_id = updated_discourse.comments["c"]
    |> Enum.at(0)
    |> Enum.at(0)
    |> Enum.at(2)
    child_discourse = Repo.get_by!(Discourse, parent_discourse_id: updated_discourse.id)
    assert child_discourse_id == child_discourse.id
  end

  test "new_point adds a point to the discourse", %{socket: socket, discourse: discourse} do
    {:ok, _, socket} = Phoenix.Socket.assign(socket, :user_id, discourse.replier_id)
    |> subscribe_and_join(DiscourseChannel, "discourses:" <> discourse.id)
    ref = push socket, "new_point", %{"body" => "point four"}
    assert_reply ref, :ok, %{}
    updated_discourse = Decomposite.Repo.get(Decomposite.Discourse, discourse.id)
    assert updated_discourse.points["p"] == ["point one", "point two", "point three", "point four"]
  end

  test "new_comment adds a comment to the discourse", %{socket: socket, discourse: discourse, commenter: commenter} do
    ref = push socket, "new_comment", %{"body" => "comment two", "point_index" => 3}
    assert_reply ref, :ok, %{}
    updated_discourse = Decomposite.Repo.get(Decomposite.Discourse, discourse.id)
    assert updated_discourse.comments["c"] == [[["comment one", commenter.id]], [], [], [["comment two", discourse.initiator_id]]]
  end
end
