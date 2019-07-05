defmodule ArtemisWeb.ViewHelper.Navigation do
  use Phoenix.HTML

  import ArtemisWeb.Config.Navigation

  @doc """
  Generates primary nav from nav items
  """
  def render_primary_nav(conn, user) do
    nav_items = nav_items_for_current_user(user)

    links =
      Enum.map(nav_items, fn {section, items} ->
        label = section

        path =
          items
          |> hd
          |> Keyword.get(:path)

        content_tag(:li) do
          link(label, to: path.(conn))
        end
      end)

    content_tag(:ul, links)
  end

  @doc """
  Generates footer nav from nav items
  """
  def render_footer_nav(conn, user) do
    nav_items = nav_items_for_current_user(user)

    sections =
      Enum.map(nav_items, fn {section, items} ->
        links =
          Enum.map(items, fn item ->
            label = Keyword.get(item, :label)
            path = Keyword.get(item, :path)

            content_tag(:li) do
              link(label, to: path.(conn))
            end
          end)

        content_tag(:div, class: "section") do
          [
            content_tag(:h5, section),
            content_tag(:ul, links)
          ]
        end
      end)

    case sections == [] do
      true ->
        nil

      false ->
        per_column =
          (length(sections) / 3)
          |> Float.ceil()
          |> trunc()

        chunked = Enum.chunk_every(sections, per_column)

        Enum.map(chunked, fn sections ->
          content_tag(:div, sections, class: "column")
        end)
    end
  end

  @doc """
  Filter nav items by current users permissions
  """
  def nav_items_for_current_user(user) do
    Enum.reduce(get_nav_items(), [], fn {section, potential_items}, acc ->
      verified_items =
        Enum.filter(potential_items, fn item ->
          verify = Keyword.get(item, :verify)

          verify.(user)
        end)

      case verified_items == [] do
        true -> acc
        false -> [{section, verified_items} | acc]
      end
    end)
  end
end
