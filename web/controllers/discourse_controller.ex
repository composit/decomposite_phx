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
            limit: 1
    results = Decomposite.Repo.all(query)
    discourse = hd(results)
    render(conn, "show.html", discourse: discourse)
  end
end
