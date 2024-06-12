defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer
  alias LiveViewStudioWeb.VolunteerFormComponent

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Volunteers.subscribe()
    end
    volunteers = Volunteers.list_volunteers()

    socket =
      socket
      |> stream(
        :volunteers, volunteers
      )
      |> assign(count: length(volunteers))

      IO.inspect(socket.assigns.streams.volunteers, label: "mount")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
     <.live_component module={VolunteerFormComponent} id={:new} count={@count} />
      <pre>
      </pre>
      <div id="volunteers" phx-update="stream">
        <.volunteer :for={{volunteer_id, volunteer} <- @streams.volunteers}  volunteer={volunteer} volunteer_id={volunteer_id}/>
      </div>
    </div>
    """
  end

  def volunteer(assigns) do
    ~H"""
    <div
        class={"volunteer #{if @volunteer.checked_out, do: "out"}"}
        id={@volunteer_id}
      >
        <div class="name">
          <%= @volunteer.name %>
        </div>
        <div class="phone">
          <%= @volunteer.phone %>
        </div>
        <div class="status">
          <%!--  the `id` portion in `phx-value-id` is an arbitrary value--%>
          <.button phx-click="toggle-status" phx-value-id={@volunteer.id}>
            <%= if @volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </.button>
        </div>
        <.link phx-click="delete" phx-value-id={@volunteer.id} class="delete" data-confirm="Would you like to delete this person">
          <.icon name="hero-trash-solid" />
        </.link>
      </div>
    """
  end



  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, _volunteer} = Volunteers.update_volunteer(volunteer, %{checked_out: !volunteer.checked_out})
    {:noreply, socket}
  end


  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, volunteer} = Volunteers.get_volunteer!(id)
    |> Volunteers.delete_volunteer()

    socket = stream_delete(socket, :volunteers, volunteer)
    socket = put_flash(socket, :info, "Volunteer #{volunteer.name} Succesfully deleted")
    {:noreply, socket}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
      socket = stream_insert(socket, :volunteers, volunteer, at: 0)
      socket = update(socket, :count, &(&1 + 1))

      {:noreply, socket}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    socket = stream_insert(socket, :volunteers, volunteer)

    {:noreply, socket}
  end

end
