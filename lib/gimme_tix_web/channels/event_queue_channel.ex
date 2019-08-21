defmodule GimmeTixWeb.EventQueueChannel do
  use GimmeTixWeb, :channel
  import Ecto.Query, only: [from: 2]

  def join("event_queue:" <> event_id, payload, socket) do
    if authorized?(payload) do
      event = GimmeTix.Repo.get!(GimmeTix.Event, event_id)
      socket = assign(socket, :event, event)
      # race condition here because reading and then inserting isn't atomic
      pos_in_queue = length(from(u in GimmeTix.User, where: u.event_id == ^event_id) |> GimmeTix.Repo.all())# |> GimmeTix.Repo.aggregate(:count, :id)
      IO.puts(pos_in_queue)
      {:ok, user} =  GimmeTix.User.changeset(%GimmeTix.User{}, %{event_id: event_id, pos_in_queue: pos_in_queue, uuid: UUID.uuid4()})
                      |> GimmeTix.Repo.insert()
      socket = assign(socket, :user, user)
      response = %{current_user: event.current_user, uuid: user.uuid, pos_in_queue: user.pos_in_queue}
      {:ok, response, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("buy", payload, socket) do
    event = GimmeTix.Repo.get!(GimmeTix.Event, socket.assigns[:event].id)
    {:ok, event} =  GimmeTix.Web.Event.changeset(event, %{current_user: event.current_user + 1})
                    |> GimmeTix.Repo.update()
    socket = assign(socket, :event, event)
    broadcast socket, "new_current_user", %{current_user: event.current_user}
    {:noreply, socket}
  end

  def handle_in("pass", payload, socket) do
    event = GimmeTix.Repo.get!(GimmeTix.Event, socket.assigns[:event].id)
    {:ok, event} =  GimmeTix.Web.Event.changeset(event, %{current_user: event.current_user + 1})
                    |> GimmeTix.Repo.update()
    socket = assign(socket, :event, event)
    broadcast socket, "new_current_user", %{current_user: event.current_user}
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
