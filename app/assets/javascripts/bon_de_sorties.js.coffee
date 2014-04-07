jQuery ->
  if $("#bon-de-sortie").length

    # clic sur le bouton creer un bon de sortie
    # Appel l'action 'create' du controller
    $("#createBds").on 'click', (e) ->
      console.log 'prout'
      e.preventDefault()
      form = $("form#bon-de-sortie")
      url = form.prop('action')
      console.log url
      ids = []
      $(".selectEbsdd").each (e) ->
        ids.push $(this).val()

      console.log ids
      console.log form.prop('method')
      if ids.length
        console.log "not ok"
        authenticityToken = $("meta[name='csrf-token']").attr("content")
        form.append('<input name="authenticity_token" type="hidden" value="' + authenticityToken + '">')
        console.log form
        alert "Désolé, cette fonction n'est pas encore active"
        #form.submit()
      else
        console.log "not ok"
        div = '<div class="alert alert-danger">Veuillez selectionner au moins un eBSDD !</div>'
        $(div).hide().insertAfter($("body .container .navbar")).fadeIn(400).delay(2000).fadeOut(500)

    console.log $("#destinataire").data("destinations")
    $("#destinataire").select2
      allowClear: true
      width: 400
      data: $("#destinataire").data("destinations")

    $("#destinataire").select2("enable", false)

    url = $("#bon-de-sortie").data('url')
    console.log url
    $("#type_dechet").select2
      allowClear: true
      width: 780
      ajax:
        dataType: "json"
        url: url
        quietMillis: 200
        type: 'post'
        data: (term, page) ->
          pageNum: page,
          query: term
        results: (data) ->
          console.log(data)
          results: data

    $("#type_dechet").on 'change', (e) ->
      console.log e.val
      $("#chauffe").prop('checked', false)
      $("#alert-poids").fadeOut(400)
      $("#poids").text(0)

      if !!e.val
        #url = $("#ebsdds_list").data('url').split("/").slice(0,-1).join('/') + '/' + e.val
        $("#spinner").spin()
        url = $("#ebsdds_list").data('url')
        console.log url
        $.post(url, denomination: e.val).fail(clamerde)

    displayEbsdds = (d,s) ->
      console.log d
      console.log s

    clamerde = (d,s) ->
      console.log d
      console.log d.responseText

    $("#chauffe").on 'change', (e) ->
      $(".selectEbsdd").each (i,e) ->
        checked = $(this).prop('checked')
        $(this).prop('checked', !checked)
      calculEtAffichePoids()

    $("#ebsdds_list").on 'change', ".selectEbsdd", (e) ->
      calculEtAffichePoids()


    calculEtAffichePoids = () ->
      $("#alert-poids").fadeIn(600) if $("#alert-poids").is(":hidden")
      poidsTotal = 0
      # on parcourt chaque ligne, on récupère le poids si la case est cochée, et on ajoute et met à jour le poids
      $("#ebsdds_list tbody tr").each (i,e) ->
        if $(this).find('td:first input').prop('checked')
          poids = parseFloat($(this).find('td:eq(3)').text().replace("kg", "").trim())
          poidsTotal += poids
          console.log poids
          console.log poidsTotal
      $("#poids").text(poidsTotal)
