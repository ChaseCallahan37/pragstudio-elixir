defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  # mount
  def mount(_params, _session, socket) do
    IO.inspect(self(), label: "MOUNT")
    socket =
      socket
      |> assign(
        brightness: 10,
        temp: "3000"
      )

    {:ok, socket}
  end

  # render
  def render(assigns) do
    ~H"""
      <h1>Front Porth Light</h1>
      <div id="light">
        <div class="meter">
          <span style={"width: #{@brightness}%; background: #{temp_color(@temp)}"}>
            <%= @brightness %>%
          </span>

        </div>
          <button phx-click="off">
            <img src ="/images/light-off.svg">
          </button>

          <button phx-click="down">
            <img src ="/images/down.svg">
          </button>

          <button phx-click="random">
            <img src ="/images/fire.svg">
          </button>

          <button phx-click="up">
            <img src="images/up.svg">
          </button>

          <button phx-click="on">
            <img src ="/images/light-on.svg">
          </button>

          <form phx-change="slide">
            <input type="range" min="0" max="100"
              phx-debounce="100" name="brightness" value={@brightness} />
          </form>

          <form phx-change="change-temp">
            <div class="temps">
              <%= for temp <- ["3000", "4000", "5000"] do %>
                <div>
                  <input type="radio" id={temp} name="temp" value={temp} checked={temp == @temp}/>
                  <label for={temp}><%= temp %></label>
                </div>
              <% end %>
            </div>
          </form>
      </div>
    """
  end

  # handle_events

  def handle_event("on", _, socket) do
    socket =
      socket
      |> assign(brightness: 100)

    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket =
      socket
      |> assign(brightness: 0)

    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket =
      socket
      |> assign(brightness: &min(100, &1 + 10))

    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket =
      socket
      |> assign(brightness: &max(0, &1 - 10))

    {:noreply, socket}
  end

  def handle_event("random", _, socket) do
    socket =
      socket
      |> assign(brightness: Enum.random(0..100))

    {:noreply, socket}
  end

  def handle_event("slide", %{"brightness" => r}, socket) do
    socket = socket
    |> assign(brightness: r)

    {:noreply, socket}
  end

  def handle_event("change-temp", %{"temp" => t}, socket) do
    socket = socket
    |> assign(
        temp: t
      )

    {:noreply, socket}
  end


  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"
end
