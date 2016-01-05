defmodule Decomposite.SessionController do
  use Decomposite.Web, :controller

  def create(conn, %{"session" => session_params, "returner" => returner}) do
    case Decomposite.Session.signin(session_params, Decomposite.Repo) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> redirect(to: returner)
      :error ->
        conn
        |> put_flash(:error, "Wrong!")
        |> redirect(to: returner)
    end
  end

  def delete(conn, %{"returner" => returner}) do
    conn
    |> delete_session(:current_user_id)
    |> redirect(to: returner)
  end
end
