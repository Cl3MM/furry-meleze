jQuery ->
  <% Rails.logger.debug render(partial: 'ebsdds/edit/cadre1_producteur_info', object: @producteur, as: :producteur) %>
  x = "<%= escape_javascript(render(partial: 'ebsdds/edit/cadre1_producteur_info', object: @producteur, as: :producteur))%>"
  console.log x
  $("#producteur_info").html(x)
  $(".disabled").each ->
    $(this).prop('disabled', true) unless $(this).val() == ""
