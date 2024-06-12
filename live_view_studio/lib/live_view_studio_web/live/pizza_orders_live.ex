defmodule LiveViewStudioWeb.PizzaOrdersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.PizzaOrders
  import Number.Currency

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        pizza_orders: PizzaOrders.list_pizza_orders(),
        options: %{},
        pizza_order_count: PizzaOrders.count_pizzas()
      )


    {:ok, socket, temporary_assigns: [pizza_orders: []]}
  end

  def handle_params(params, _uri, socket) do
    sort_by = find_sort_by(params)
    sort_order = find_sort_order(params)

    page = string_to_integer(params["page"], 1)
    per_page = string_to_integer(params["per_page"], 10)

    options = %{
      sort_order: sort_order,
      sort_by: sort_by,
      page: page,
      per_page: per_page
    }

    pizzas = PizzaOrders.list_pizza_orders(options)

    socket = assign(socket,
      options: options,
      pizza_orders: pizzas
    )

    {:noreply, socket}
  end



  def handle_event("per-page-select", %{"per-page" => per_page}, socket) do
    params = %{per_page: per_page}

    {:noreply, push_patch(socket, to: ~p"/pizza-orders?#{params}")}
  end

  defp find_sort_by(%{"sort_by" => sort_by})
    when sort_by in ~w(size style topping1 topping2 price) do
      String.to_atom(sort_by)
  end

  defp find_sort_by(_), do: :id

  defp find_sort_order(%{"sort_order" => sort_order})
    when sort_order in ~w(asc desc) do
      String.to_atom(sort_order)
  end

  defp find_sort_order(_), do: :asc

  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true
  def sort_link(assigns) do
    ~H"""
    <.link patch={~p"/pizza-orders?#{[sort_by: @sort_by, sort_order: pick_sort_order(@options.sort_order)]}"}>
    <%= render_slot(@inner_block) %>
    <%= render_pointer(@sort_by, @options) %>
    </.link>
    """
  end

  defp render_pointer(column, %{sort_by: sort_by, sort_order: sort_order})
    when sort_by == column do
      case sort_order do
        :asc -> "👆"
        :desc -> "👇"
      end
    end
  defp render_pointer(_column, _), do: ""

  defp pick_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end

  defp string_to_integer(nil, default), do: default
  defp string_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} -> number
      :error -> default
    end
  end

  defp pages(options, donation_count) do
    page_count = ceil(donation_count / options.per_page)

    for page_number <- (options.page - 2)..(options.page + 2),
      page_number > 0 do
        if page_number <= page_count do
          current_page? = page_number == options.page
          {page_number, current_page?}
        end
      end
  end

  defp more_pages?(options, pizza_order_count) do
    options.page * options.per_page < pizza_order_count
  end
end
