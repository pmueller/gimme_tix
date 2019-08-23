defmodule GimmeTixWeb.EventQueueChannel do
  alias GimmeTix.User
  alias GimmeTix.Event
  alias GimmeTix.Repo
  use GimmeTixWeb, :channel
  import Ecto.Query, only: [from: 2]

  def join("event_queue:" <> event_id, %{"uuid" => uuid}, socket) do
    event = get_event(event_id)
    socket = assign(socket, :event, event)

    user = get_event_user_by_uuid(uuid, event.id)
    socket = assign(socket, :user, user)

    response = %{current_user: event.current_user, uuid: user.uuid, pos_in_queue: user.pos_in_queue}
    send(self, :after_join)
    {:ok, response, socket}
  end

  def join("event_queue:" <> event_id, %{}, socket) do
    event = get_event(event_id)
    socket = assign(socket, :event, event)

    # race condition here because reading and then inserting isn't atomic
    pos_in_queue = Repo.one(from u in User, where: u.event_id == ^event_id, select: count(u.id))
    {:ok, user} =  User.changeset(%User{}, %{event_id: event_id, pos_in_queue: pos_in_queue, uuid: UUID.uuid4()})
                    |> Repo.insert()
    socket = assign(socket, :user, user)

    response = %{current_user: event.current_user, uuid: user.uuid, pos_in_queue: user.pos_in_queue}
    send(self, :after_join)
    {:ok, response, socket}
  end

  def handle_info(:after_join, socket) do
    event = get_event(socket.assigns[:event].id)
    push socket, "new_current_user", %{current_user: event.current_user}
    {:noreply, socket}
  end

  def handle_in("buy", %{"uuid" => uuid}, socket) do
    event = get_event(socket.assigns[:event].id)
    user = get_event_user_by_uuid(uuid, event.id)
    if event.current_user == user.pos_in_queue do
      socket = advance_queue(socket)
    end
    {:noreply, socket}
  end

  def handle_in("pass", %{"uuid" => uuid}, socket) do
    event = get_event(socket.assigns[:event].id)
    user = get_event_user_by_uuid(uuid, event.id)
    if event.current_user == user.pos_in_queue do
      socket = advance_queue(socket)
    end
    {:noreply, socket}
  end

  # for testing, advance to the next spot in line
  def handle_in("skip", payload, socket) do
    socket = advance_queue(socket)
    {:noreply, socket}
  end

  defp get_event(event_id) do
    Repo.get!(Event, event_id)
  end

  defp get_event_user_by_uuid(uuid, event_id) do
    Repo.get_by!(User, [uuid: uuid, event_id: event_id])
  end

  defp advance_queue(socket) do
    event = get_event(socket.assigns[:event].id)
    {:ok, event} =  Event.changeset(event, %{current_user: event.current_user + 1})
                    |> Repo.update()
    socket = assign(socket, :event, event)
    broadcast socket, "new_current_user", %{current_user: event.current_user}
    socket
  end
end
