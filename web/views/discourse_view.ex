require Integer

defmodule Decomposite.DiscourseView do
  use Decomposite.Web, :view

  def sayer_name(discourse, thing_index) do
    if Integer.is_even(thing_index) do
      discourse.initiator.name
    else
      discourse.replier.name
    end
  end
end
