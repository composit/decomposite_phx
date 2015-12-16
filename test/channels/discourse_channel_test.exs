defmodule Decomposite.DiscourseChannelTest do
  use Decomposite.ChannelCase

  alias Decomposite.DiscourseChannel

  setup do
    {:ok, user} = create_test_user

    {:ok, discourse} = initialize_discourses(%{
      points: %{"p" => ["point one"]},
      comments: %{"c" => [[["comment one", "abc123"]]]},
      initiator_id: user.id,
      replier_id: user.id,
      updater_id: user.id,
    })

    {:ok, _, socket} =
      Phoenix.Socket.assign(socket, :user_id, user.id)
      |> subscribe_and_join(DiscourseChannel, "discourses:" <> discourse.id)

    {:ok, socket: socket, discourse: discourse, user: user}
  end

  test "new_point adds a point to the discourse", %{socket: socket, discourse: discourse} do
    ref = push socket, "new_point", %{"body" => "point two"}
    assert_reply ref, :ok, %{}
    updated_discourse = Decomposite.Repo.get(Decomposite.Discourse, discourse.id)
    assert updated_discourse.points["p"] == ["point one", "point two"]
  end

  test "new_comment adds a comment to the discourse", %{socket: socket, discourse: discourse, user: user} do
    ref = push socket, "new_comment", %{"body" => "comment two", "point_index" => 3}
    assert_reply ref, :ok, %{}
    updated_discourse = Decomposite.Repo.get(Decomposite.Discourse, discourse.id)
    assert updated_discourse.comments["c"] == [[["comment one", "abc123"]], [], [], [["comment two", user.id]]]
  end
end
