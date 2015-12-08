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
end
