defmodule Decomposite.RegistrationController do
  use Decomposite.Web, :controller
  alias Decomposite.User

  def create(conn, %{"user" => user_params, "returner" => returner}) do
    changeset = User.changeset(%User{}, user_params)

    case Decomposite.Registration.create(changeset, Decomposite.Repo) do
      {:ok, changeset} ->
        conn
        |> put_session(:current_user_id, changeset.id)
        |> redirect(to: returner)
      {:error, changeset} ->
        conn
        |> redirect(to: returner)
    end
  end
end
