require Integer

defmodule Decomposite.Discourse do
  use Decomposite.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "discourses" do
    field :things_said, :map
    field :parent_thing_said_index, :integer
    belongs_to :parent_discourse, Decomposite.ParentDiscourse, type: :binary_id
    belongs_to :initiator, Decomposite.User
    belongs_to :replier, Decomposite.User
    field :updater_id, :integer, virtual: true

    timestamps
  end

  @required_fields ~w(things_said parent_discourse_id parent_thing_said_index initiator_id replier_id)
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
    updater_id = changeset.params["updater_id"]
    initiator_id = get_field(changeset, :initiator_id)
    replier_id = get_field(changeset, :replier_id)
    length_of_things_said = length(get_field(changeset, :things_said)["t"])
    cond do
      Integer.is_even(length_of_things_said) && updater_id == replier_id ->
        changeset
      Integer.is_odd(length_of_things_said) && updater_id == initiator_id ->
        changeset
      true ->
        add_error(changeset, :updater_id, "does not have permissions to update this discourse")
    end
  end
end
