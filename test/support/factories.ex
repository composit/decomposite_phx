defmodule Decomposite.Factories do
  alias Decomposite.Discourse
  alias Decomposite.Repo
  alias Decomposite.User

  def create_test_user(params \\ %{}) do
    crypted_password = Comeonin.Bcrypt.hashpwsalt("testpass")
    changeset = User.changeset(%User{}, Dict.merge(%{name: "testuser", password: "testpass", crypted_password: crypted_password}, params))
    Repo.insert(changeset)
  end

  def initialize_discourses(params, first_user \\ nil) do
    if !first_user do
      {:ok, first_user} = Repo.insert(%User{name: "first", password: "first"})
    end
    {:ok, second_user} = Repo.insert(%User{name: "second", password: "second"})
    {:ok, first_discourse} = Repo.insert(%Discourse{points: %{"p" => ["point one"]}, initiator: first_user, replier: second_user, comments: %{"c" => []}})
    attrs = valid_discourse_attrs
    |> Dict.merge(%{parent_discourse_id: first_discourse.id, parent_point_index: 0, initiator_id: first_user.id, replier_id: second_user.id, updater_id: second_user.id})
    |> Dict.merge(params)
    Discourse.changeset(%Discourse{}, attrs)
    |> Repo.insert
  end

  def valid_discourse_attrs do
    %{parent_discourse_id: Ecto.UUID.generate, parent_point_index: 42, points: %{"p" => []}, comments: %{"c" => []}, initiator_id: 123, replier_id: 456, updater_id: 456}
  end
end
