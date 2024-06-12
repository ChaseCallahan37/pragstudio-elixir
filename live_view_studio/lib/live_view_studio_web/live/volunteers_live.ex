defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    changeset = Volunteers.change_volunteer(%Volunteer{})
    form = to_form(changeset)

    socket =
      socket
      |> stream(
        :volunteers, volunteers
      )
      |> assign(
        form: form
      )

      IO.inspect(socket.assigns.streams.volunteers, label: "mount")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
     <.volunteer_form for={@form} />
      <pre>
      </pre>
      <div id="volunteers" phx-update="stream">
        <.volunteer :for={{volunteer_id, volunteer} <- @streams.volunteer}  volunteer={volunteer} volunteer_id={volunteer_id}/>
      </div>
    </div>
    """
  end

  def volunteer_form(assigns) do
    ~H"""
    <.form for={@form} phx-submit="save" phx-change="validate">
      <.input field={@form[:name]} placeholder="Name" autocomplete="off" phx-debounce="2000"/>
      <.input field={@form[:phone]} placeholder="Phone" type="tel" autocomplete="off" phx-debounce="blur"/>
      <.button phx-disable-with="Saving...">Check In</.button>
    </.form>
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
  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, volunteer} ->
        socket = stream_insert(socket, :volunteers, volunteer, at: 0)
        IO.inspect(socket.assigns.streams.volunteers, label: "save")
        changeset = Volunteers.change_volunteer(%Volunteer{})

        socket = put_flash(socket, :info, "Succesfully Added")
        {:noreply, assign(socket, form: to_form(changeset))}
      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end

  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, volunteer} = Volunteers.update_volunteer(volunteer, %{checked_out: !volunteer.checked_out})
    socket = stream_insert(socket, :volunteers, volunteer)
    {:noreply, socket}
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do

    IO.inspect(socket.assigns.streams.volunteers, label: "Validate")

    changeset = %Volunteer{}
    |> Volunteers.change_volunteer(volunteer_params)
    |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, volunteer} = Volunteers.get_volunteer!(id)
    |> Volunteers.delete_volunteer()

    socket = stream_delete(socket, :volunteers, volunteer)
    socket = put_flash(socket, :info, "Volunteer #{volunteer.name} Succesfully deleted")
    {:noreply, socket}
  end
end
