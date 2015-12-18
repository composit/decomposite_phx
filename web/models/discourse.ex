require Integer

defmodule Decomposite.Discourse do
  use Decomposite.Web, :model
  alias Decomposite.Repo

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "discourses" do
    field :points, :map
    field :comments, :map
    belongs_to :parent_discourse, Decomposite.ParentDiscourse, type: :binary_id
    field :parent_point_index, :integer
    field :parent_comment_index, :integer
    belongs_to :initiator, Decomposite.User
    belongs_to :replier, Decomposite.User
    field :updater_id, :integer, virtual: true

    timestamps
  end

  @required_fields ~w(points comments parent_discourse_id parent_point_index parent_comment_index initiator_id replier_id updater_id)
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
    |> validate_parenthood
  end

  def validate_authorized(changeset) do
    cond do
      changed?(changeset, :points) ->
        validate_changed_points(changeset)
      true ->
        changeset
    end
  end

  defp changed?(changeset, field) do
    Enum.member?(Map.keys(changeset.changes), field)
  end

  defp validate_changed_points(changeset) do
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
  end

  def validate_parenthood(changeset) do
    if parent_discourse = Repo.get(Decomposite.Discourse, get_field(changeset, :parent_discourse_id)) do
      parent_point_index = get_field(changeset, :parent_point_index)
      parent_point = parent_discourse.points["p"]
      |> Enum.at(parent_point_index)
      parent_pointer_id = cond do
        Integer.is_even(parent_point_index) ->
          parent_discourse.initiator_id
        Integer.is_odd(parent_point_index) ->
          parent_discourse.replier_id
      end
      [parent_comment, parent_commenter_id] = parent_discourse.comments["c"]
      |> Enum.at(parent_point_index)
      |> Enum.at(get_field(changeset, :parent_comment_index))
      points = get_field(changeset, :points)
      new_first_point = Enum.at(points["p"], 0)
      new_second_point = Enum.at(points["p"], 1)
      cond do
        new_first_point != parent_point ->
          add_error(changeset, :points, "do not match the parent point")
        new_second_point != parent_comment ->
          add_error(changeset, :points, "do not match the parent comment")
        get_field(changeset, :initiator_id) != parent_pointer_id ->
          add_error(changeset, :initiator_id, "does not match the parent")
        get_field(changeset, :replier_id) != parent_commenter_id ->
          add_error(changeset, :replier_id, "does not match the parent")
        true ->
          changeset
      end
    else
      add_error(changeset, :parent_discourse, "does not exist")
    end
  end
end
