defmodule Decomposite.Router do
  use Decomposite.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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

    resources "/d", DiscourseController, only: [:show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Decomposite do
  #   pipe_through :api
  # end
end
