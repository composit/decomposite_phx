defmodule Decomposite.SessionTest do
  use Decomposite.ModelCase
  use Decomposite.ConnCase

  alias Decomposite.Session
  @session Plug.Session.init(
    store: :cookie,
    key: "_key",
    encryption_salt: "salty",
    signing_salt: "salterson"
  )

  setup do
    user = %Decomposite.User{
      name: "testuser",
      crypted_password: Comeonin.Bcrypt.hashpwsalt("testpass")
    } |> Repo.insert!

    session_data = %{id: user.id}
    conn =
      conn(:get, "/signin")
      |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
      |> Plug.Session.call(@session)
      |> Plug.Conn.fetch_session()
    {:ok, conn: conn, user: user, session_data: session_data}
  end

  test "signs in authenticated user", context do
    {:ok, signed_in_user} = Session.signin(%{"name" => "testuser", "password" => "testpass"}, Repo)
    assert signed_in_user.id == context[:user].id
  end

  test "does not sign in unauthenticated user" do
    response = Session.signin(%{"name" => "testuser", "password" => "otherpass"}, Repo)
    assert response == :error
  end

  test "returns current user", context do
    current_user = context[:conn]
    |> Plug.Conn.put_session(:current_user_id, context[:user].id)
    |> Session.current_user
    assert current_user.id == context[:user].id
  end

  test "indicates when a user is signed in", context do
    assert context[:conn]
    |> Plug.Conn.put_session(:current_user_id, context[:user].id)
    |> Session.signed_in?
  end

  test "indicates when a user is not signed in", context do
    assert false == Session.signed_in?(context[:conn])
  end
end
