defmodule GimmeTixWeb.EventQueueChannelTest do
  use GimmeTixWeb.ChannelCase
  alias GimmeTix.Event
  alias GimmeTix.User
  alias GimmeTix.Repo

  setup do
    attrs = %{name: "Hockey game", current_user: 0}
    {:ok, event} = %Event{}
                   |> Event.changeset(attrs)
                   |> Repo.insert()
    {:ok, _, socket} =
      socket(GimmeTixWeb.UserSocket, "user_id", %{some: :assign})
      |> subscribe_and_join(GimmeTixWeb.EventQueueChannel, "event_queue:#{event.id}")

    {:ok, user1} = %User{}
                  |> User.changeset(%{event_id: event.id, uuid: "abcd-1234", pos_in_queue: 0})
                  |> Repo.insert()

    {:ok, user2} = %User{}
                  |> User.changeset(%{event_id: event.id, uuid: "zxcv-5678", pos_in_queue: 100})
                  |> Repo.insert()


    {:ok, socket: socket}
  end

  describe "buy when the uuid matches a user not at the front of the line" do
    test "the next user id is not broadcast", %{socket: socket} do
      push socket, "buy", %{"uuid" => "zxcv-5678"}
      refute_broadcast "new_current_user", %{current_user: 1}
    end
  end

  describe "buy when the uuid matches the user at the front of the line" do
    test "the next user id is broadcast", %{socket: socket} do
      push socket, "buy", %{"uuid" => "abcd-1234"}
      assert_broadcast "new_current_user", %{current_user: 1}
    end
  end

  describe "pass when the uuid matches a user not at the front of the line" do
    test "the next user id is not broadcast", %{socket: socket} do
      push socket, "pass", %{"uuid" => "zxcv-5678"}
      refute_broadcast "new_current_user", %{current_user: 1}
    end
  end

  describe "pass when the uuid matches the user at the front of the line" do
    test "the next user id is broadcast", %{socket: socket} do
      push socket, "pass", %{"uuid" => "abcd-1234"}
      assert_broadcast "new_current_user", %{current_user: 1}
    end
  end

  test "skip broadcasts the next user", %{socket: socket} do
    push socket, "skip", %{}
    assert_broadcast "new_current_user", %{current_user: 1}
  end
end
