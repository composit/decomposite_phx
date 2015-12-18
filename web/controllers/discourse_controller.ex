defmodule Decomposite.DiscourseController do
  use Decomposite.Web, :controller
  alias Decomposite.Discourse
  alias Decomposite.User
  alias Decomposite.DiscourseFactory

  def show(conn, %{"id" => id}) do
    discourse = Repo.get!(Discourse, id)
    |> Repo.preload([:initiator, :replier])
    render(conn, "show.html", discourse: discourse)
  end

  def landing(conn, _params) do
    query = from d in Discourse,
            order_by: [desc: d.updated_at],
            preload: [:initiator, :replier],
            limit: 10
    discourse = Repo.all(query)
    |> Enum.reverse
    |> hd
    render(conn, "show.html", discourse: discourse)
  end

  def new(conn, %{"parent_discourse_id" => parent_discourse_id, "parent_point_index" => parent_point_index, "parent_comment_index" => parent_comment_index}) do
    initiator_id = conn.assigns[:user_id]
    discourse = DiscourseFactory.build_from_parent(parent_discourse_id, parent_point_index, parent_comment_index, initiator_id)
    render(conn, "show.html", discourse: discourse)
  end
end
