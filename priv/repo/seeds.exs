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

  def run do
    drop_existing_data
    decomposite = %User{name: "decomposite"} |> Repo.insert!
    add_initial_cycle(decomposite)
  end

  def drop_existing_data do
    Mix.shell.info "dropping existing data"

    Repo.delete_all(Discourse)
    Repo.delete_all(User)
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
end

Seeder.run
