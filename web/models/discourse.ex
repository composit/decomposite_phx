defmodule Decomposite.Discourse do
  use Decomposite.Web, :model

  schema "discourses" do
    field :things_said, :map
    field :parent_thing_said_index, :integer
    belongs_to :parent_discourse, Decomposite.ParentDiscourse

    timestamps
  end

  @required_fields ~w(things_said parent_thing_said_index)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
