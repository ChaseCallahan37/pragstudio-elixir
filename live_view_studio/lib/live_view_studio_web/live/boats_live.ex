defmodule LiveViewStudioWeb.BoatsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Boats

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        filter: %{type: "", prices: []},
        boats: Boats.list_boats()
      )

    {:ok, socket, temporary_assigns: [boats: []]}
  end

  def handle_params(params, _session, socket) do
    filter = %{
      type: params["type"] || "",
      prices: params["prices"] || [""]
    }
    boats = Boats.list_boats(filter)

    {:noreply, assign(socket, boats: boats, filter: filter)}
  end

  def render(assigns) do
    ~H"""

    <.badge id="test-id" phx-click="remove" label="Hello" class="bg-blue-200 font-bold"/>
    <.star_icon />
    <h1>Daily Boat Rentals</h1>
    <.promo >Save 25%!
    </.promo>
      <div id="boats">
      <.filter_form filter={@filter} />
        <div class="boats">
          <.boat :for={boat <- @boats} boat={boat} />
      </div>
    </div>

    <.promo expiration={5}>Hurry!
    <:legal>Only 3 left</:legal>
    </.promo>
    """
  end

  attr :filter, :map, required: true
  def filter_form(assigns) do
    ~H"""
    <form phx-change="filter">
        <div class="filters">
          <select name="type">
            <%= Phoenix.HTML.Form.options_for_select(
              type_options(),
              @filter.type
            ) %>
          </select>
          <div class="prices">
            <%= for price <- ["$", "$$", "$$$"] do %>
              <input
                type="checkbox"
                name="prices[]"
                value={price}
                id={price}
                checked={price in @filter.prices}
              />
              <label for={price}><%= price %></label>
            <% end %>
            <input type="hidden" name="prices[]" value="" />
          </div>
        </div>
      </form>

    """
  end

  attr :boat, LiveViewStudio.Boats.Boat, required: true
  def boat(assigns) do
    ~H"""
     <div class="boat">
          <img src={@boat.image} />
          <div class="content">
            <div class="model">
              <%= @boat.model %>
            </div>
            <div class="details">
              <span class="price">
                <%= @boat.price %>
              </span>
              <span class="type">
                <%= @boat.type %>
              </span>
            </div>
          </div>
        </div>
    """
  end

  def handle_event("filter", %{"type" => type, "prices" => prices}, socket) do


    params = %{type: type, prices: prices}

    socket = push_patch(socket, to: ~p"/boats?#{params}")

    {:noreply, socket}
  end

  defp type_options do
    [
      "All Types": "",
      Fishing: "fishing",
      Sporting: "sporting",
      Sailing: "sailing"
    ]
  end
end
