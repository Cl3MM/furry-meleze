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
  else
    $("#ebsdds_list").fadeOut(500) if $("#ebsdds_list").is(":visible")
    msg = "Aucun eBSDD trouvé pour cette catégorie de déchet. Veuillez :
      <br/
      <ul>
        <li>réessayer en cochant la case 'EcoDDS uniquement',</li>
        <li>choisir une autre catégorie</li>
      </ul>"
    div = '<div class="alert alert-danger">'+msg+'</div>'
    $(div).hide().insertAfter($("body .container .navbar")).fadeIn(400).delay(3500).fadeOut(500)
