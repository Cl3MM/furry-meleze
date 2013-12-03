jQuery ->
  $("a.touletip").tooltip()

  entreposage_visibility = (x) ->
    $(".entreposage-provisoire :input").each ->
      $(this).prop('disabled', x)

  if $("#ebsdd_mode_transport").length > 0
    $("#ebsdd_mode_transport").on 'change', ()->
      if $(this).val() == "1"
        $("#ebsdd_recepisse").prop('disabled', false)
      else
        $("#ebsdd_recepisse").prop('disabled', true)

  if $("#ebsdd_entreposage_provisoire_true").length > 0
    $("#ebsdd_entreposage_provisoire_true").on 'change', ()->
      if $(this).prop('checked') == true
        entreposage_visibility(false)

  if $("#ebsdd_entreposage_provisoire_false").length > 0
    if $("#ebsdd_entreposage_provisoire_false").prop('checked') == true
      entreposage_visibility(true)
    $("#ebsdd_entreposage_provisoire_false").on 'change', ()->
      if $(this).prop('checked') == true
        entreposage_visibility(true)
