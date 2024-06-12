defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Flights
  alias LiveViewStudio.Airports

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        airport: "",
        flights: [],
        loading: false,
        matches: %{}
      )

    {:ok, socket}
  end


  def handle_event("search", %{"airport" => airport}, socket) do
    send(self(), {:run_search, airport})
    socket =
      assign(socket,
        airport: airport,
        flights: [],
        loading: true
      )

      {:noreply, socket}
  end

  def handle_event("suggest", %{"airport" => prefix}, socket) do
    matches = Airports.suggest(prefix)

    socket = assign(socket,
      matches: matches
    )

    {:noreply, socket}
  end

  def handle_info({:run_search, airport}, socket) do
    socket = socket
    |> assign(
      flights: Flights.search_by_airport(airport),
      loading: false
    )

    {:noreply, socket}
  end
end
