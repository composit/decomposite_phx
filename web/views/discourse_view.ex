require Integer
require IEx

defmodule Decomposite.DiscourseView do
  use Decomposite.Web, :view

  def sayer_name(discourse, point_index) do
    if Integer.is_even(point_index) do
      discourse.initiator.name
    else
      discourse.replier.name
    end
  end

  def comments_by_point_index(comments, point_index) do
    Enum.at(comments["c"], point_index) || []
  end

  def find_user(user_id) do
    Decomposite.Repo.get!(Decomposite.User, user_id)
  end
end
