defmodule Decomposite.SessionController do
  use Decomposite.Web, :controller

  def new(conn, _params) do
    conn
    |> put_layout(false)
    |> render("new.html")
  end

  def create(conn, %{"session" => session_params}) do
    case Decomposite.Session.signin(session_params, Decomposite.Repo) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "Signed in")
        |> redirect(to: "/")
      :error ->
        conn
        |> put_flash(:info, "Wrong!")
        |> put_layout(false)
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> delete_session(:current_user_id)
    |> put_flash(:info, "Signed out")
    |> redirect(to: "/")
  end
end
