defmodule LiveViewStudioWeb.VolunteerFormComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(socket) do
    changeset = Volunteers.change_volunteer(%Volunteer{})
    form = to_form(changeset)

    {:ok, assign(socket, form: form)}
  end

  def update(assigns, socket) do
    socket = socket
    |> assign(assigns)
    |> assign(:count, assigns.count + 2)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
    <div> Go for it, youll be volunteer # <%= @count %>!</div>
<%!--  In order for liveview to know this module is where the handle_events are stord, we must specify the target.
      In this case we put myself becuase the live component implements the callbacks--%>
      <.form for={@form} phx-submit="save" phx-change="validate" phx-target={@myself}>
        <.input field={@form[:name]} placeholder="Name" autocomplete="off" phx-debounce="2000"/>
        <.input field={@form[:phone]} placeholder="Phone" type="tel" autocomplete="off" phx-debounce="blur"/>
        <.button phx-disable-with="Saving...">Check In</.button>
      </.form>
    </div>
    """
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, _volunteer} ->
        changeset = Volunteers.change_volunteer(%Volunteer{})

        socket = put_flash(socket, :info, "Succesfully Added")
        {:noreply, assign(socket, form: to_form(changeset))}
      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end

  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do

    changeset = %Volunteer{}
    |> Volunteers.change_volunteer(volunteer_params)
    |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end
end
