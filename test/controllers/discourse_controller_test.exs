defmodule Decomposite.DiscourseControllerTest do
  use Decomposite.ConnCase
  alias Decomposite.Discourse

  setup do
    {:ok, discourse} = initialize_discourses(%{})

    {:ok, discourse: discourse}
  end

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "point one"
  end

  test "GET /d/123", %{discourse: discourse} do
    conn = get conn(), "/d/" <> discourse.id
    assert html_response(conn, 200) =~ "point one"
  end

  test "GET /d/new/123/0/0", %{discourse: discourse} do
    Discourse.changeset(discourse, %{comments: %{"c" => [[["comment one", discourse.replier_id]]]}})
    |> Repo.update

    session_opts = Plug.Session.init(store: :cookie, key: "_app", encryption_salt: "abc", signing_salt: "abc")
    conn = conn()
    |> assign(:user_id, discourse.initiator_id)
    |> get("/d/new/#{discourse.id}/0/0")
    assert html_response(conn, 200) =~ "point one"
    assert html_response(conn, 200) =~ "comment one"
  end
end
