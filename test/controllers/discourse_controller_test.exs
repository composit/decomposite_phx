defmodule Decomposite.DiscourseControllerTest do
  use Decomposite.ConnCase

  setup do
    {:ok, user} = create_test_user
    {:ok, discourse} = initialize_discourses(%{
      points: %{"p" => ["test it up"]},
      initiator_id: user.id,
      replier_id: user.id,
      updater_id: user.id
    })

    {:ok, discourse: discourse}
  end

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "test it up"
  end

  test "GET /d/123", %{discourse: discourse} do
    conn = get conn(), "/d/" <> discourse.id
    assert html_response(conn, 200) =~ "test it up"
  end
end
