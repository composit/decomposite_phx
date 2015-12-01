defmodule Decomposite.RegistrationController do
  use Decomposite.Web, :controller
  alias Decomposite.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    conn
    |> put_layout(false)
    |> render(changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Decomposite.Registration.create(changeset, Decomposite.Repo) do
      {:ok, changeset} ->
        conn
        |> put_session(:current_user_id, changeset.id)
        |> put_flash(:info, "Your account was made")
        |> redirect(to: "/")
      {:error, changeset} ->
        conn
        |> put_flash(:info, "Not able to make your account")
        |> put_layout(false)
        |> render("new.html", changeset: changeset)
    end
  end
end
