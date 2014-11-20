# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require toastr

toastr.options = {
  "closeButton": true,
  "debug": false,
  "progressBar": true,
  "positionClass": "toast-bottom-right",
  "onclick": null,
  "showDuration": "300",
  "hideDuration": "1000",
  "timeOut": "2000",
  "extendedTimeOut": "1000",
  "showEasing": "swing",
  "hideEasing": "linear",
  "showMethod": "fadeIn",
  "hideMethod": "fadeOut"
}

$ ->
  $(".touletip").tooltip()
  console.log 'Up and running'

  peseOk = (data)->
    toastr.success "Poids net: #{data.net.val} kg"
    console.log data
    $("#tare_poids").val(data.net.val)

  failed = (data)->
    console.group "Erreur"
    console.log data
    console.end
    toastr.error "Un problème est survenu, veuillez réessayer"

  razOk = (data)->
    toastr.success "Balance remise à zéro, récupération du poids de la tare..."
    setTimeout( ( ()-> $.get("/balance/pese").done(peseOk).fail(failed) ), 500)

  $("#tare").on 'click', (e)->
    $.get("/balance/cmd/z").done(razOk).fail(failed)
