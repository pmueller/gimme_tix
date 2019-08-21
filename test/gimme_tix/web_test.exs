defmodule GimmeTix.WebTest do
  use GimmeTix.DataCase

  alias GimmeTix.Web

  describe "events" do
    alias GimmeTix.Web.Event

    @valid_attrs %{current_user: 42, name: "some name"}
    @update_attrs %{current_user: 43, name: "some updated name"}
    @invalid_attrs %{current_user: nil, name: nil}

    def event_fixture(attrs \\ %{}) do
      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Web.create_event()

      event
    end

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Web.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Web.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Web.create_event(@valid_attrs)
      assert event.current_user == 42
      assert event.name == "some name"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Web.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      assert {:ok, %Event{} = event} = Web.update_event(event, @update_attrs)
      assert event.current_user == 43
      assert event.name == "some updated name"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Web.update_event(event, @invalid_attrs)
      assert event == Web.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Web.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Web.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Web.change_event(event)
    end
  end
end
