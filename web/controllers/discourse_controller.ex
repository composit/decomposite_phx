defmodule Decomposite.DiscourseController do
  use Decomposite.Web, :controller
  alias Decomposite.Discourse

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
end
