require Integer

defmodule Decomposite.DiscourseView do
  use Decomposite.Web, :view

  def sayer_name(discourse, point_index) do
    if Integer.is_even(point_index) do
      discourse.initiator.name
    else
      discourse.replier.name
    end
  end

  def visible_comments(discourse, point_index, user_id) do
    comments_by_point_index(discourse.comments, point_index)
    |> Enum.filter fn(comment) ->
      cond do
        belongs_to_user(discourse, point_index, user_id) ->
          true
        Enum.count(comment) == 3 ->
          true
        Enum.at(comment, 1) == user_id ->
          true
        true ->
          false
      end
    end
  end

  defp comments_by_point_index(comments, point_index) do
    Enum.at(comments["c"], point_index) || []
  end

  def find_user(user_id) do
    Decomposite.Repo.get!(Decomposite.User, user_id)
  end

  def belongs_to_user(discourse, point_index, user_id) do
    cond do
      Integer.is_even(point_index) && user_id == discourse.initiator_id ->
        true
      Integer.is_odd(point_index) && user_id == discourse.replier_id ->
        true
      true ->
        false
    end
  end
end
