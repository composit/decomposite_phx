defmodule Decomposite.Router do
  use Decomposite.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_user_data
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Decomposite do
    pipe_through :browser # Use the default browser stack

    get "/", DiscourseController, :landing
    resources "/registrations", RegistrationController, only: [:new, :create]
    get "/signin", SessionController, :new
    post "/signin", SessionController, :create
    delete "/signout", SessionController, :delete

    get "/d/new/:parent_discourse_id/:parent_point_index/:parent_comment_index", DiscourseController, :new
    resources "/d", DiscourseController, only: [:show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Decomposite do
  #   pipe_through :api
  # end

  defp put_user_data(conn, _) do
    if current_user_id = Plug.Conn.get_session(conn, :current_user_id) do
      token = Phoenix.Token.sign(conn, "user socket", current_user_id)
      assign(conn, :user_token, token)
      assign(conn, :user_id, current_user_id)
    else
      conn
    end
  end
end
