jQuery ->
  $('.datepicker').datepicker
    dateFormat: 'dd-mm-yy',
    $.datepicker.regional[ "fr" ]

  # Enable / Disable $(".disabled")
  disable = (x) ->
    $(".disabled").each ->
      $(this).prop('disabled', x) unless $(this).val() == ""
  disable( true ) if $('.disabled').length

  # Active / Désactive l'édition du cadre 15
  entreposage_visibility = (x) ->
    $(".entreposage-provisoire :input").each ->
      $(this).prop('disabled', x)

  # Ajax call
  remote_call = (url, success, { type, datatype } ) ->
    type ?= "GET"
    datatype ?= 'json'
    $.ajax
      type: type,
      url: url,
      dataType: 'json',
      success: (data) ->
        success(data)

  if $("#edit").length

    #$("#e1").select2()
    $("#ebsdd_producteur_id").select2
      width: 507

    # Envoie une requête au serveur pour afficher les info du producteur choisi
    $("#ebsdd_producteur_id").on 'change', (e) ->
      val =  $(this).val()
      $("#ebsdd_producteur_attributes_id").val(val)
      url = '/producteurs/' + val + '.js'
      $.get( url)

    # Active le recepisse
    if $("#ebsdd_mode_transport").val() != "1"
      $("#ebsdd_recepisse").prop('disabled', true)

    # Authorise l'edition du champ recepise
    $("#ebsdd_mode_transport").on 'change', ()->
      if $(this).val() == "1"
        $("#ebsdd_recepisse").prop('disabled', false)
      else
        $("#ebsdd_recepisse").prop('disabled', true)

    # Active / Déactive le cadre 15 quand Oui est cliqué au cadre 2
    $("#ebsdd_entreposage_provisoire_true").on 'change', ()->
      if $(this).prop('checked') == true
        entreposage_visibility(false)

    # Affiche le cadre 15 lors du chargement
    if $("#ebsdd_entreposage_provisoire_false").prop('checked') == true
      entreposage_visibility(true)

    # Active / Déactive le cadre 15 quand Oui est cliqué au cadre 2
    $("#ebsdd_entreposage_provisoire_false").on 'change', ()->
      if $(this).prop('checked') == true
        entreposage_visibility(true)

    # Change le code rubrique dechet et la mention au titre des reglnt en fonction du champ dechet denomination usuelle
    $("#ebsdd_dechet_nomenclature").on 'change', (evt) ->
      denomination = $(this).val()
      $("#code_rubrique_dechet").html denomination
      $("#ebsdd_dechet_denomination").val denomination

    # Change le code rubrique dechet et la denomination usuelle en fonction du champ mention au titre des reglnt
    $("#ebsdd_dechet_denomination").on 'change', (evt) ->
      denomination = $(this).val()
      $("#code_rubrique_dechet").html denomination
      $("#ebsdd_dechet_nomenclature").val denomination

    # Ajoute une plaque d'immatriculation
    $("#add-immatriculation").on 'click', (evt) ->
      plaque = $("#immatriculation-new").val()
      console.log plaque
      if plaque.length
        $.ajax
          type: 'POST',
          url: '/immatriculation/' + plaque,
          dataType: 'json',
          success: (data) ->
            unless !jQuery.isEmptyObject(data)
              alert "La plaque d'immatriculation " + data.valeur + " a bien été créée"
              option = '<option value="' + data.id + '">' + data.valeur + "</option>"
              $('#ebsdd_immatriculation').prepend( option )
              $('#ebsdd_immatriculation').val(data.id)
