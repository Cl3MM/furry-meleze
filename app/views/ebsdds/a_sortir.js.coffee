jQuery ->
  $("#spinner").spin(false)
  $("#destinataire").select2("enable", true)
  $("#destinataire").select2('val', '<%= @destinataire %>')
  $("#codedr").select2("enable", true)
  $("#codedr").select2('val', '<%= @codedr %>')
  ebsdds = '<%= j render partial: "bon_de_sorties/choisir_ebsdds", locals: { ebsdds: @ebsdds } %>'
  if !!ebsdds
    $("#ebsdds_list tbody").replaceWith(ebsdds)
    $("#ebsdds_list").fadeIn(500) if $("#ebsdds_list").is(":hidden")
