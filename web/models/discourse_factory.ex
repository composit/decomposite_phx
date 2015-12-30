defmodule Decomposite.DiscourseFactory do
  alias Decomposite.Discourse
  alias Decomposite.Repo
  alias Decomposite.User

  def build_from_parent(discourse_id, point_index, comment_index, initiator_id, body \\ nil) do
    %Discourse{}
    |> Map.merge(fields_from_parent(discourse_id, point_index, comment_index, initiator_id, body))
  end
  
  def fields_from_parent(discourse_id, point_index, comment_index, initiator_id, body \\ nil) do
    discourse = Repo.get!(Discourse, discourse_id)
    point = discourse.points["p"]
    |> Enum.at(point_index)
    comment_info = discourse.comments["c"]
    |> Enum.at(point_index)
    |> Enum.at(comment_index)
    comment = Enum.at(comment_info, 0)
    replier_id = Enum.at(comment_info, 1)
    points = [point, comment]
    if body, do: points = points ++ [body]
    %{
      initiator_id: initiator_id,
      initiator: Repo.get!(User, initiator_id),
      replier_id: replier_id,
      replier: Repo.get!(User, replier_id),
      parent_discourse_id: discourse.id,
      parent_discourse: discourse,
      parent_point_index: point_index,
      parent_comment_index: comment_index,
      points: %{"p" => points},
      comments: %{"c" => []},
    }
  end
end
