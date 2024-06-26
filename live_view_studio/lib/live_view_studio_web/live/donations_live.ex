defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    socket = assign(socket,
     donation_count: Donations.count_donations()
    )
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _uri, socket) do
    sort_by = valid_sort_by(params)
    sort_order = valid_sort_order(params)

    page = param_to_integer(params["page"], 1)
    per_page = param_to_integer(params["per_page"], 5)

    options = %{sort_by: sort_by, sort_order: sort_order, page: page,
      per_page: per_page}

    donations = Donations.list_donations(options)

    {:noreply, assign(socket,
      options: options,
      donations: donations
      )}
  end

  defp param_to_integer(nil, default), do: default
  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} -> number
      :error -> default
    end
  end

  defp valid_sort_by(%{"sort_by" => sort_by})
    when sort_by in ~w(item quantity days_until_expire) do

      String.to_atom(sort_by)
  end

  defp valid_sort_by(_), do: :id

  defp valid_sort_order(%{"sort_order" => sort_order})
    when sort_order in ~w(asc desc) do

      String.to_atom(sort_order)
    end

  defp valid_sort_order(_), do: :asc

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end

  attr :options, :map, required: true
  attr :sort_by, :atom, required: true
  slot :inner_block, required: true
  defp sort_link(%{sort_by: sort_by, options: %{sort_order: sort_order} = options} = assigns) do
    params = %{
      options
      | sort_by: sort_by,
      sort_order: next_sort_order(sort_order)
    }

    assigns = assign(assigns, params: params)

    ~H"""
    <.link patch={~p"/donations?#{@params}"}>
          <%= render_slot(@inner_block) %>
          <%= sort_indicator(@sort_by, @options) %>
      </.link>
    """
  end

  defp sort_indicator(column, %{sort_by: sort_by, sort_order: sort_order})
    when column == sort_by do
      case sort_order do
        :asc -> "👆"
        :desc -> "👇"
      end
  end

  defp sort_indicator(_, _), do: ""

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}

    socket = push_patch(socket, to: ~p"/donations?#{params}")

    {:noreply, socket}
  end

  defp valid_per_page(per_page) when per_page in ~w(5 10 15 20) do
    String.to_integer(per_page)
  end

  defp more_pages?(options, donation_count) do
    options.page * options.per_page < donation_count
  end

  defp valid_per_page(_), do: 5

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
end
