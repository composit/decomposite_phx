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

  def visible_comments(discourse, user_id) do
    Enum.with_index(discourse.comments["c"])
    |> Enum.map fn({point_comments, point_index}) ->
      visible_point_comments(point_comments, point_index, user_id, discourse)
    end
  end

  def visible_point_comments(comments, point_index, user_id, discourse) do
    Enum.filter comments, fn(comment) ->
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
