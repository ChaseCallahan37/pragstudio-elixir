defmodule LiveViewStudioWeb.VehiclesLive do
  alias LiveViewStudio.Vehicles
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        vehicles: [],
        loading: false,
        matches: []
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>🚙 Find a Vehicle 🚘</h1>
    <div id="vehicles">
      <form phx-submit="search" phx-change="suggest">
        <input
          type="text"
          name="query"
          value=""
          placeholder="Make or model"
          autofocus
          autocomplete="off"
          readonly={@loading}
          debounce="1000"
          list="suggest"
        />

        <button>
          <img src="/images/search.svg" />
        </button>
      </form>

      <datalist id="suggest">
        <option :for={make_model <- @matches} value={make_model}> <%= make_model %> </option>
      </datalist>
      <.loading_icon loading={@loading}/>
      <div class="vehicles">
        <ul>
          <li :for={vehicle <- @vehicles}>
            <span class="make-model">
              <%= vehicle.make_model %>
            </span>
            <span class="color">
              <%= vehicle.color %>
            </span>
            <span class={"status #{vehicle.status}"}>
              <%= vehicle.status %>
            </span>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("search", %{"query" => query}, socket) do
    send(self(), {:vehicle_search, query})

    socket = assign(socket,
      vehicles: [],
      loading: true
    )

    {:noreply, socket}
  end

  def handle_event("suggest", %{"query" => prefix}, socket) do
    socket = assign(socket,
      matches: Vehicles.suggest(prefix)
    )

    {:noreply, socket}
  end

  def handle_info({:vehicle_search, query}, socket) do
    socket = assign(socket,
      vehicles: Vehicles.search(query),
      loading: false
    )

    {:noreply, socket}
  end
end
