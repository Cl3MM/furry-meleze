jQuery ->
  $("#producteur_info").html "<%= escape_javascript(render(partial: 'ebsdds/edit/cadre1_producteur_info', object: @producteur, as: :producteur))%>"
  $(".disabled").each ->
    $(this).prop('disabled', true) unless $(this).val() == ""
