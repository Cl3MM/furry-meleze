jQuery ->
  if $("#bon-de-sortie").length

    # clic sur le bouton creer un bon de sortie
    # Appel l'action 'create' du controller
    $("#createBds").on 'click', (e) ->
      e.preventDefault()
      form = $("form#bon-de-sortie")
      url = form.prop('action')
      ids = []
      $(".selectEbsdd").each (e) ->
        ids.push $(this).val() if $(this).prop("checked")

      if ids.length
        authenticityToken = $("meta[name='csrf-token']").attr("content")
        form.append('<input name="authenticity_token" type="hidden" value="' + authenticityToken + '">')
        form.submit()
      else
        console.log "not ok"
        div = '<div class="alert alert-danger">Veuillez selectionner au moins un eBSDD !</div>'
        $(div).hide().insertAfter($("body .container .navbar")).fadeIn(400).delay(2000).fadeOut(500)

    console.log $("#destinataire").data("destinations")
    $("#destinataire").select2
      allowClear: true
      width: 780
      data: $("#destinataire").data("destinations")

    console.log $("#codedr").data("codedr")
    $("#codedr").select2
      allowClear: true
      width: 780
      data: $("#codedr").data("codedr")

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

    $("#type_dechet").on 'select2-selecting', (e) ->
      console.log e.val
      $("#chauffe").prop('checked', false)
      $("#alert-poids").fadeOut(400)
      $("#poids").text(0)

      if !!e.val
        #url = $("#ebsdds_list").data('url').split("/").slice(0,-1).join('/') + '/' + e.val
        $("#spinner").spin()
        url = $("#ebsdds_list").data('url')
        data = 
          produit_id: e.val
          is_ecodds: $("#ecodds").prop("checked")
        console.log url
        $.post(url, data).fail(clamerde)

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
      $("#poidsHidden").val(poidsTotal)
