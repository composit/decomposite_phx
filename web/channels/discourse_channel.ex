defmodule Decomposite.DiscourseChannel do
  use Phoenix.Channel

  def join("discourses:" <> _discourse_id, _params, socket) do
    if authorized?(socket) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("new_point", %{"body" => body}, socket) do
    discourse = get_discourse_by_topic(socket.topic)
    points = discourse.points["p"]
    new_points = points ++ [body]
    user_id = socket.assigns[:user_id]
    changeset = Decomposite.Discourse.changeset(discourse, %{points: %{"p" => new_points}, updater_id: user_id})
    {response, changeset} = Decomposite.Repo.update(changeset)

    {:reply, response, socket}
  end

  def handle_in("new_comment", %{"body" => body, "point_index" => point_index}, socket) do
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
    changeset = Decomposite.Discourse.changeset(discourse, %{comments: %{"c" => new_comments}, updater_id: commenter_id})
    Decomposite.Repo.update(changeset)

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
    Decomposite.Repo.get!(Decomposite.Discourse, discourse_id)
  end

  defp authorized?(socket) do
    !!socket.assigns[:user_id]
  end
end
