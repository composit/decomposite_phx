require Integer

defmodule Decomposite.DiscourseController do
  use Decomposite.Web, :controller
  alias Decomposite.Discourse
  alias Decomposite.User
  alias Decomposite.DiscourseFactory

  def show(conn, %{"id" => id}) do
    discourse = Repo.get!(Discourse, id)
    |> Repo.preload([:initiator, :replier])
    # in case they're creating a new user
    changeset = User.changeset(%User{})
    conn
    |> assign(:discourse, discourse)
    |> assign(:changeset, changeset)
    |> render("show.html")
  end

  def landing(conn, _params) do
    query = from d in Discourse,
            order_by: [desc: d.updated_at],
            preload: [:initiator, :replier],
            limit: 10
    discourse = Repo.all(query)
    |> Enum.reverse
    |> hd
    # in case they're creating a new user
    changeset = User.changeset(%User{})
    conn
    |> assign(:discourse, discourse)
    |> assign(:changeset, changeset)
    |> render("show.html")
  end

  def new(conn, %{"parent_discourse_id" => parent_discourse_id, "parent_point_index" => parent_point_index, "parent_comment_index" => parent_comment_index}) do
    initiator_id = conn.assigns[:user_id]
    {parent_point_index, _} = Integer.parse(parent_point_index)
    {parent_comment_index, _} = Integer.parse(parent_comment_index)
    discourse = DiscourseFactory.build_from_parent(parent_discourse_id, parent_point_index, parent_comment_index, initiator_id)

    # in case they're creating a new user
    changeset = User.changeset(%User{})

    render(conn, "show.html", discourse: discourse, changeset: changeset)
  end
end
