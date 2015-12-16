defmodule Decomposite.RegistrationTest do
  use Decomposite.ModelCase

  alias Decomposite.Registration

  test "hashes user password" do
    {:ok, user} = Decomposite.User.changeset(%Decomposite.User{}, %{name: "testuser", password: "testpass"})
    |> Registration.create(Repo)
    assert user.crypted_password
  end
end
