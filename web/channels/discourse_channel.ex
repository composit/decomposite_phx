require Integer

defmodule Decomposite.DiscourseChannel do
  use Phoenix.Channel
  alias Decomposite.Repo
  alias Decomposite.Discourse
  alias Decomposite.DiscourseFactory

  def join("discourses:" <> discourse_id, _params, socket) do
    {:ok, %{message: "joined channel: discourses:#{discourse_id}"}, socket}
  end

  def terminate(_message, socket) do
    # do something when the user leaves a channel
  end

  def handle_in("new_discourse", %{"parent_discourse_id" => parent_discourse_id, "parent_point_index" => parent_point_index, "parent_comment_index" => parent_comment_index,  "body" => body}, socket) do
    initiator_id = socket.assigns[:user_id]
    discourse_fields = DiscourseFactory.fields_from_parent(parent_discourse_id, parent_point_index, parent_comment_index, initiator_id, body)
    {response, changeset} = Discourse.changeset(%Discourse{}, Dict.merge(discourse_fields, %{updater_id: initiator_id}))
    |> Repo.insert
    if response == :ok do
      parent_discourse = Repo.get!(Discourse, parent_discourse_id)
      comments = parent_discourse.comments["c"]
      parent_point_comments = Enum.at(comments, parent_point_index)
      |> List.update_at(parent_comment_index, &(&1 ++ [changeset.id]))
      comments = List.replace_at(comments, parent_point_index, parent_point_comments)
      user_id = socket.assigns[:user_id]
      Discourse.changeset(parent_discourse, %{comments: %{"c" => comments}, updater_id: user_id})
      |> Repo.update!
    end

    {:reply, {response, %{discourse_id: changeset.id}}, socket}
  end

  def handle_in("new_point", %{"body" => body}, socket) do
    discourse = get_discourse_by_topic(socket.topic)
    points = discourse.points["p"]
    new_points = points ++ [body]
    user_id = socket.assigns[:user_id]
    changeset = Discourse.changeset(discourse, %{points: %{"p" => new_points}, updater_id: user_id})
    {response, changeset} = Repo.update(changeset)

    {:reply, response, socket}
  end

  def handle_in("new_comment", %{"body" => body, "point_index" => point_index}, socket) do
    {point_index, _} = Integer.parse(point_index)
    discourse = get_discourse_by_topic(socket.topic)
    comments = discourse.comments["c"]
    point_comments = Enum.at(comments, point_index)
    commenter_id = socket.assigns[:user_id]
    new_comment = [body, commenter_id]
    if point_comments do
      new_point_comments = point_comments ++ [[body, commenter_id]]
      new_comments = List.replace_at(comments, point_index, new_point_comments)
    else
      new_comments = insert_with_empties(comments, point_index, new_comment)
    end
    Discourse.changeset(discourse, %{comments: %{"c" => new_comments}, updater_id: commenter_id})
    |> Repo.update

    {:reply, :ok, socket}
  end

  defp insert_with_empties(comments, point_index, new_comment) do
    if point_index == Enum.count(comments) do
      comments ++ [[new_comment]]
    else
      comments_plus_one = comments ++ [[]]
      insert_with_empties(comments_plus_one, point_index, new_comment)
    end
  end

  defp get_discourse_by_topic(topic) do
    [_, discourse_id] = String.split(topic, ":", parts: 2)
    Repo.get!(Discourse, discourse_id)
  end
end
