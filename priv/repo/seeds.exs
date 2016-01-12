# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Decomposite.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule Seeder do
  alias Decomposite.Repo
  alias Decomposite.User
  alias Decomposite.Discourse
  alias Decomposite.DiscourseFactory

  def run(number_of_iterations) do
    drop_existing_data
    {:ok, decomposite} = add_decomposite_user
    add_initial_cycle(decomposite)
    |> populate_comments(decomposite)

    Enum.each(1..number_of_iterations, fn(x) -> populate_edges(decomposite, x) end)
  end

  def drop_existing_data do
    Mix.shell.info "dropping existing data"

    Repo.delete_all(Discourse)
    Repo.delete_all(User)
  end

  def add_decomposite_user do
    Mix.shell.info "Creating decomposite user"

    password = System.get_env("DECOMPOSITE_PASSWORD")
    Repo.insert(%User{name: "decomposite", password: password, crypted_password: Comeonin.Bcrypt.hashpwsalt(password)})
  end


  def add_initial_cycle(decomposite) do
    Mix.shell.info "Adding initial cycle"

    logos  = %Discourse{comments: %{"c" => [[["ethos", decomposite.id]],[["pathos", decomposite.id]],[["logos", decomposite.id]]]}, initiator_id: decomposite.id, parent_discourse_id: nil,      parent_point_index: 1, parent_comment_index: 0, points: %{"p" => ["logos", "ethos", "pathos"]}, replier_id: decomposite.id, updater_id: decomposite.id}
    |> Repo.insert!

    ethos  = %Discourse{comments: %{"c" => [[["pathos", decomposite.id]],[["logos", decomposite.id]],[["ethos", decomposite.id]]]}, initiator_id: decomposite.id, parent_discourse_id: logos.id, parent_point_index: 1, parent_comment_index: 0, points: %{"p" => ["ethos", "pathos", "logos"]}, replier_id: decomposite.id, updater_id: decomposite.id}
    |> Repo.insert!

    pathos = %Discourse{comments: %{"c" => [[["logos", decomposite.id]],[["ethos", decomposite.id]],[["pathos", decomposite.id]]]}, initiator_id: decomposite.id, parent_discourse_id: ethos.id, parent_point_index: 1, parent_comment_index: 0, points: %{"p" => ["pathos", "logos", "ethos"]}, replier_id: decomposite.id, updater_id: decomposite.id}
    |> Repo.insert!

    Mix.shell.info "making initial cycle recursive"
    # update parent params to link these discourses recursively
    Discourse.changeset(logos,  %{comments: %{"c" => [[["ethos", decomposite.id]],[["pathos", decomposite.id, ethos.id]],[["logos", decomposite.id]]]}, parent_discourse_id: pathos.id})
    |> Repo.update!

    Discourse.changeset(ethos,  %{comments: %{"c" => [[["pathos", decomposite.id]],[["logos", decomposite.id, pathos.id]],[["ethos", decomposite.id]]]}})
    |> Repo.update!

    Discourse.changeset(pathos, %{comments: %{"c" => [[["logos", decomposite.id]],[["ethos", decomposite.id, logos.id]],[["pathos", decomposite.id]]]}})
    |> Repo.update!

    [logos, ethos, pathos]
  end

  def populate_comments(discourses, decomposite) do
    Mix.shell.info "populating comments"

    Enum.each(discourses, fn(discourse) -> populate_discourse_comments(discourse, decomposite) end)
  end

  def populate_discourse_comments(discourse, decomposite) do
    Enum.each(Enum.with_index(discourse.points["p"]), fn({point, point_index}) -> populate_point_comments(point, point_index, discourse.id, decomposite) end)
  end

  def populate_point_comments(point, point_index, discourse_id, decomposite) do
    discourse = Repo.get(Discourse, discourse_id)
    point_comments = discourse.comments["c"] |> Enum.at(point_index)
    comment_index = Enum.count(point_comments) - 1

    if(comment_index < 0) do
      # create comment
      comment = get_next_word(point)
      {:ok, discourse} = add_comment_to_discourse(discourse, point_index, comment, decomposite)
      comment_index = comment_index + 1
      point_comments = discourse.comments["c"]
      |> Enum.at(comment_index)
    end

    parent_comment = Enum.at(point_comments, comment_index)
    if(Enum.count(parent_comment) < 3) do # only create a child discourse if one does not exist
      # create child discourse
      discourse_starter = get_next_word(Enum.at(parent_comment, 0))
      discourse_fields = DiscourseFactory.fields_from_parent(discourse.id, point_index, comment_index, decomposite.id, discourse_starter)
      {response, changeset} = Discourse.changeset(%Discourse{}, Dict.merge(discourse_fields, %{updater_id: decomposite.id, comments: %{"c" => [[],[],[]]}}))
      |> Repo.insert

      # update child_discourse_id in parent
      if response == :ok do
        comments = discourse.comments["c"]
        point_comments = Enum.at(comments, point_index)
        |> List.update_at(comment_index, &(&1 ++ [changeset.id]))
        comments = List.replace_at(comments, point_index, point_comments)
        Discourse.changeset(discourse, %{comments: %{"c" => comments}, updater_id: decomposite.id})
        |> Repo.update!
      end
    end
  end

  def add_comment_to_discourse(discourse, point_index, comment, commenter) do
    comments = discourse.comments["c"]
    point_comments = Enum.at(comments, point_index)
    new_point_comments = point_comments ++ [[comment, commenter.id]]
    new_comments = List.replace_at(comments, point_index, new_point_comments)

    Discourse.changeset(discourse, %{comments: %{"c" => new_comments}, updater_id: commenter.id})
    |> Repo.update
  end

  def populate_edges(updater, x) do
    Mix.shell.info "ITERATION: #{x}"
    import Ecto.Query, only: [from: 1, from: 2]
    query = from d in Discourse, where: d.initiator_id == ^updater.id and d.replier_id == ^updater.id
    discourses = Repo.all(query)
    populate_comments(discourses, updater)
  end

  def get_next_word(word) do
    case word do
      "logos" ->
        "ethos"
      "ethos" ->
        "pathos"
      "pathos" ->
        "logos"
    end
  end
end

Seeder.run(42)
