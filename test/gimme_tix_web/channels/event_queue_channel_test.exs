defmodule GimmeTixWeb.EventQueueChannelTest do
  use GimmeTixWeb.ChannelCase
  alias GimmeTix.Event
  alias GimmeTix.Repo

  setup do
    attrs = %{name: "Hockey game", current_user: 0}
    {:ok, event} = %Event{}
                   |> Event.changeset(attrs)
                   |> Repo.insert()
    {:ok, _, socket} =
      socket(GimmeTixWeb.UserSocket, "user_id", %{some: :assign})
      |> subscribe_and_join(GimmeTixWeb.EventQueueChannel, "event_queue:#{event.id}")

    {:ok, socket: socket}
  end

  test "buy broadcasts the next user", %{socket: socket} do
    push socket, "buy", %{}
    assert_broadcast "new_current_user", %{current_user: 1}
  end

  test "pass broadcasts the next user", %{socket: socket} do
    push socket, "buy", %{}
    assert_broadcast "new_current_user", %{current_user: 1}
  end
end
