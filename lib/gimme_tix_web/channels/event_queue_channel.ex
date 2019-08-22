defmodule GimmeTixWeb.EventQueueChannel do
  alias GimmeTix.User
  alias GimmeTix.Event
  alias GimmeTix.Repo
  use GimmeTixWeb, :channel
  import Ecto.Query, only: [from: 2]

  def join("event_queue:" <> event_id, payload, socket) do
    event = get_event(event_id)
    socket = assign(socket, :event, event)
    # race condition here because reading and then inserting isn't atomic
    pos_in_queue = Repo.one(from u in User, where: u.event_id == ^event_id, select: count(u.id))
    # also need to deal with weird corner cases like current_user being way higher than pos_in_queue
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

  def handle_in("buy", payload, socket) do
    socket = advance_queue(socket)
    {:noreply, socket}
  end

  def handle_in("pass", payload, socket) do
    socket = advance_queue(socket)
    {:noreply, socket}
  end

  defp get_event(event_id) do
    Repo.get!(Event, event_id)
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
