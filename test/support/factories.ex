defmodule Decomposite.Factories do
  alias Decomposite.Discourse
  alias Decomposite.Repo
  alias Decomposite.User
  alias Decomposite.DiscourseFactory

  def create_test_user(params \\ %{}) do
    name = "testuser#{:random.uniform(1000)}"
    crypted_password = Comeonin.Bcrypt.hashpwsalt("testpass")
    User.changeset(%User{}, Dict.merge(%{name: name, password: "testpass", crypted_password: crypted_password}, params))
    |> Repo.insert
  end

  def initialize_discourses(params, first_user \\ nil) do
    if !first_user do
      {:ok, first_user} = create_test_user
    end
    {:ok, second_user} = create_test_user
    {:ok, first_discourse} = Repo.insert(%Discourse{points: %{"p" => ["point one"]}, initiator_id: first_user.id, replier_id: second_user.id, comments: %{"c" => [[["point two", second_user.id]]]}})
    second_discourse_attrs = DiscourseFactory.fields_from_parent(first_discourse.id, "0", "0", first_user.id, "point three")
    attrs = valid_discourse_attrs
    |> Dict.merge(%{updater_id: first_user.id})
    |> Dict.merge(second_discourse_attrs)
    |> Dict.merge(params)
    Discourse.changeset(%Discourse{}, attrs)
    |> Repo.insert
  end

  def valid_discourse_attrs do
    %{parent_discourse_id: Ecto.UUID.generate, parent_point_index: 42, parent_comment_index: 77, points: %{"p" => []}, comments: %{"c" => []}, initiator_id: 123, replier_id: 456, updater_id: 456}
  end
end
