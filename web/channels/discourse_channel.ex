defmodule Decomposite.DiscourseChannel do
  use Phoenix.Channel

  def join("discourses:" <> discourse_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("new_thing_said", %{"body" => body}, socket) do
    discourse_id = List.last(String.split(socket.topic, ":", parts: 2))
    discourse = Decomposite.Repo.get!(Decomposite.Discourse, discourse_id)
    things_said = discourse.things_said["t"]
    new_things_said = things_said ++ [body]
    changeset = Decomposite.Discourse.changeset(discourse, %{things_said: %{"t" => new_things_said}})
    Decomposite.Repo.update(changeset)

    {:noreply, socket}
  end
end
