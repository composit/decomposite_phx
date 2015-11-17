defmodule Decomposite.HelloController do
  use Decomposite.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
