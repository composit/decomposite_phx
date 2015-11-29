defmodule Decomposite.DiscourseController do
  use Decomposite.Web, :controller
  alias Decomposite.Discourse

  def show(conn, %{"id" => id}) do
    discourse = Repo.get!(Discourse, id)
    render(conn, "show.html", discourse: discourse)
  end
end
