defmodule Decomposite.DiscourseChannel do
  use Phoenix.Channel

  def join("discourses:" <> discourse_id, _params, socket) do
    discourse = Decomposite.Repo.get!(Decomposite.Discourse, discourse_id)
    user_id = socket.assigns[:user_id]
    if user_id == discourse.initiator_id or user_id == discourse.replier_id do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("new_point", %{"body" => body}, socket) do
    [_, discourse_id] = String.split(socket.topic, ":", parts: 2)
    discourse = Decomposite.Repo.get!(Decomposite.Discourse, discourse_id)
    points = discourse.points["p"]
    new_points = points ++ [body]
    user_id = socket.assigns[:user_id]
    changeset = Decomposite.Discourse.changeset(discourse, %{points: %{"p" => new_points}, updater_id: user_id})
    Decomposite.Repo.update(changeset)

    {:noreply, socket}
  end
end
