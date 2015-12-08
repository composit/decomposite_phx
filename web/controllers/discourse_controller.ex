defmodule Decomposite.DiscourseController do
  use Decomposite.Web, :controller
  alias Decomposite.Discourse

  def show(conn, %{"id" => id}) do
    discourse = Repo.get!(Discourse, id)
    render(conn, "show.html", discourse: discourse)
  end

  def landing(conn, _params) do
    query = from d in Discourse,
            order_by: [desc: d.inserted_at],
            preload: [:initiator, :replier],
            limit: 1
    results = Repo.all(query)
    discourse = hd(results)
    render(conn, "show.html", discourse: discourse)
  end
end
