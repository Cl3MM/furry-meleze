# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  disable = (x) ->
    $(".disabled").each ->
      $(this).prop('disabled', x)
  disable( true ) if $('.disabled').length

  if $(".datepicker").length
    $('.datepicker').datepicker
      dateFormat: 'dd-mm-yy',
      $.datepicker.regional[ "fr" ]

  if $("#edit_producteur").length
    $("#producteur_is_collecteur").on "change", (e) ->
      console.log $(this).prop('checked')
      val = not $(this).prop('checked')
      console.log val
      for attr in ['recepisse', 'mode_transport', 'limite_validite']
        $("#producteur_#{ attr }").prop('disabled', val)

  if $("#monthly-stats-by-type-donut").length and $("#monthly-stats-by-type-donut").data("graph").length
    Morris.Donut( {
      element: 'monthly-stats-by-type-donut',
      data: $("#monthly-stats-by-type-donut").data("graph")
    } )
  else
    msg = "<div class='alert alert-info'>Aucune donnée pour les dates sélectionnées</div>"
    $("#monthly-stats-by-type-donut").append(msg)
  if $("#monthly-stats-by-type-bar").length and $("#monthly-stats-by-type-bar").data("graph").length
    Morris.Bar({
      element: 'monthly-stats-by-type-bar',
      data: $("#monthly-stats-by-type-bar").data("graph")
      xkey: 'y',
      ykeys: 'x',
      labels: 'Poids'
    })
  else
    msg = "<div class='alert alert-info'>Aucune donnée pour les dates sélectionnées</div>"
    $("#monthly-stats-by-type-bar").append(msg)
