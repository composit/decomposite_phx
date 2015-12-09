require Integer

defmodule Decomposite.Discourse do
  use Decomposite.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "discourses" do
    field :points, :map
    field :comments, :map
    field :parent_point_index, :integer
    belongs_to :parent_discourse, Decomposite.ParentDiscourse, type: :binary_id
    belongs_to :initiator, Decomposite.User
    belongs_to :replier, Decomposite.User
    field :updater_id, :integer, virtual: true

    timestamps
  end

  @required_fields ~w(points comments parent_discourse_id parent_point_index initiator_id replier_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_authorized
  end

  def validate_authorized(changeset) do
    if Enum.member?(Map.keys(changeset.changes), :points) do
      updater_id = changeset.params["updater_id"]
      initiator_id = get_field(changeset, :initiator_id)
      replier_id = get_field(changeset, :replier_id)
      number_of_points = length(get_field(changeset, :points)["p"])
      cond do
        Integer.is_even(number_of_points) && updater_id == replier_id ->
          changeset
        Integer.is_odd(number_of_points) && updater_id == initiator_id ->
          changeset
        true ->
          add_error(changeset, :updater_id, "does not have permissions to update this discourse")
      end
    else
      changeset
    end
  end
end
