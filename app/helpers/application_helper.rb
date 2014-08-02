module ApplicationHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    fa_direction = column == find_sorted_column && sort_direction == "asc" ? "up" : "down"
    css_class = "fa fa-caret-#{fa_direction}"
    direction = column == find_sorted_column && sort_direction == "asc" ? "desc" : "asc"
    title = "#{content_tag(:i, "", class: fa_direction)} &nbsp;#{title}".html_safe
    link_to title, {sort: column, direction: direction}, {:class => css_class}
    #link_to title, {sort: column, direction: direction}, {:class => css_class} do
      #content_tag :i, "", class: "fa fa-carret-down"
      #title
    #end
  end
end
