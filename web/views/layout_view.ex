defmodule Decomposite.LayoutView do
  use Decomposite.Web, :view

  def user_type(discourse, user_id) do
    if user_id do
      user = Decomposite.Repo.get!(Decomposite.User, user_id)
      initiator_id = discourse.initiator_id
      replier_id = discourse.replier_id
      case user.id do
        ^initiator_id ->
          "initiator"
        ^replier_id ->
          "replier"
        _ ->
          "commenter"
      end
    end
  end

  def user_name(conn) do
    if current_user(conn) do
      current_user(conn).name
    end
  end
end
