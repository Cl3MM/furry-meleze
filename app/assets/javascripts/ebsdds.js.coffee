jQuery ->
  $('.datepicker').datepicker
    defaultDate: "+1w"
    numberOfMonths: 3
    dateFormat: 'dd-mm-yy'
    $.datepicker.regional[ "fr" ]
  $("td.touletip").tooltip(container: "body")
  $("th.touletip").tooltip(container: "body")

  # Enable / Disable $(".disabled")
  disable = (x, id = "") ->
    $("#{ id } .disabled").each ->
      $(this).prop('disabled', x) #unless $(this).val() == ""

  disable(true, "#new_producteur") if $("#new_producteur").length
  disable( true ) if $('.disabled').length


  if $("#import_btn").length
    $('#import_btn').click (e) ->
      btn = $(this)
      btn.button('loading')
      $("form#ebsdd_import").submit()

  if $('#search').length
    # multiebsdd export / search
    #

    $("#selectall").click (e) ->
      val = $(this).prop("checked")
      $(".multiebsdd").each (td) ->
        $(this).prop("checked", val)

    $("#export_ebsdd_btn").click (e) ->
      $("form#to_export").submit()
    # actions effectuées quand le formulaire de recherche est affiché
    $("#date_min").datepicker
      defaultDate: "+1w"
      numberOfMonths: 3
      dateFormat: 'dd-mm-yy'
      onClose: (selectedDate) ->
        $("#date_max").datepicker "option", "minDate", selectedDate
      $.datepicker.regional[ "fr" ]

    $("#date_max").datepicker
      defaultDate: "+1w"
      numberOfMonths: 3
      dateFormat: 'dd-mm-yy'
      onClose: (selectedDate) ->
        $("#date_min").datepicker "option", "maxDate", selectedDate
      $.datepicker.regional[ "fr" ]

    $('#search').on 'shown.bs.modal', (e) ->
      $("#search_date_min").datepicker
        defaultDate: "+1w"
        numberOfMonths: 3
        dateFormat: 'dd-mm-yy'
        onClose: (selectedDate) ->
          $("#search_date_max").datepicker "option", "minDate", selectedDate
        $.datepicker.regional[ "fr" ]

      $("#search_date_max").datepicker
        defaultDate: "+1w"
        numberOfMonths: 3
        dateFormat: 'dd-mm-yy'
        onClose: (selectedDate) ->
          $("#search_date_min").datepicker "option", "maxDate", selectedDate
        $.datepicker.regional[ "fr" ]

      $("#search_date").datepicker
        defaultDate: "+1w"
        numberOfMonths: 3
        dateFormat: 'dd-mm-yy'
        $.datepicker.regional[ "fr" ]

  # Active / Désactive l'édition du cadre 15
  entreposage_visibility = (x) ->
    $(".entreposage-provisoire :input").each ->
      $(this).prop('disabled', x)

  if $("#edit").length

    if $("#ebsdd_collectable_id option:selected").text() == 'TRIALP'
      $("#immatriculations").show()
    else
      $("#immatriculations").hide()
    #$("#ebsdd_emetteur_nom").val $("#ebsdd_collectable_id option:selected").text()
    $("#ebsdd_emetteur_nom").val $("#ebsdd_productable_id option:selected").text()


    # éléments auxquel on va ajouter Select2 (le chiffre représente la largeur)
    toSelect = {
      1076 : [ "collectable_id" ],
      707  : [ "immatriculation", "dechet_conditionnement" ],
      507  : [ "productable_id", "destinataire_id" ],
      339  : [ "destination_id", "dechet_denomination" ],
    }
    # On parcourt le dictionaire ci dessus et on ajoute select2 à tous les éléments
    for len, arr of toSelect
      for selector in arr
        $("#ebsdd_#{ selector }").select2( containerCssClass: "form-control" )

    # On affiche le formulaire des immatriculations quand le collecteur sélectionné est TRIALP
    $("#ebsdd_collectable_id").on 'change', (e) ->
      if $("#ebsdd_collectable_id option:selected").text() == 'TRIALP'
        $("#immatriculations").show()
      else
        $("#immatriculations").hide()

    # Envoie une requête au serveur pour afficher les info du productable choisi
    #$("#ebsdd_productable_id").on 'change', (e) ->
      #val =  $(this).val()
      ##$("#ebsdd_productable_attributes_id").val(val)
      #$("#ebsdd_emetteur_nom").val $("#ebsdd_productable_id option:selected").text()
      #url = '/producteurs/' + val + '.js'
      #$.get( url)

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

    # Change le code rubrique dechet et la denomination usuelle en fonction du champ mention au titre des reglnt
    #$("#ebsdd_dechet_nomenclature").on 'change', (evt) ->
      #denomination = $(this).val()
      #$("#code_rubrique_dechet").html denomination
      #$("#ebsdd_dechet_denomination").val denomination

    # Set default value for hidden field to avoid errors
    if $("#ebsdd_dechet_denomination").length and $("input#ebsdd_dechet_nomenclature").length
      $("input#ebsdd_dechet_nomenclature").val( $("#ebsdd_dechet_denomination").val() )

    # S'il y a une erreur dans la désignation, le msg est affiché 2 fois.
    # Du coup on cache un des deux messages
    if $("input#ebsdd_dechet_nomenclature").prev().prop('class') == " text-danger" and $("input#ebsdd_dechet_nomenclature").next().prop('class') == " text-danger"
      $("input#ebsdd_dechet_nomenclature").next().hide()

    # Code D/R Cadre 11 = Code D/R Cadre 2 (Valespace, R13)
    $("#ebsdd_code_operation").val( $("#ebsdd_valorisation_prevue").val())

    destination_configuration =
      200114: ["R12", "SARPI"]
      200115: ["R12", "SARPI"]
      160904: ["R12", "SARPI"]
      200119: ["R12", "SARPI"]
      160504: ["R12", "SARPI"]
      200113: ["R12", "SARPI"]
      200127: ["D10", "TREDI"]
      150110: ["D10", "TREDI"]
      160107: ["R13", "CHIMIREC"]

    contenants = 
      200127: "BA6090"
      150110: "BA6090"
      160504: "CA0609"
      200113: "CA0609"
      200119: "CA0609"
      160107: "OT1222"
      200114: "CA0609"
      200115: "CA0609"
      160904: "CA0609"

    # Change le code rubrique dechet et la mention au titre des reglnt en fonction du champ dechet denomination usuelle
    $("#ebsdd_dechet_denomination").on 'change', (evt) ->
      denomination = $(this).val()
      $("#code_rubrique_dechet").html("#{ denomination }*")
      $("select#ebsdd_dechet_nomenclature").val(denomination)
      # On met la valeur sélectionnée dans le champ hidden car l'attribut disabled du select empeche la validation coté serveur
      $("input#ebsdd_dechet_nomenclature").val(denomination)
      for k, v of destination_configuration
        if k == denomination
          $("#ebsdd_destination_id option").each (e) ->
            if $(this).text() == v[1]
              $("#ebsdd_destination_id").val($(this).val()).trigger('change')
              $("#ebsdd_traitement_prevu").val(v[0]).trigger('change')
      # Remplis le champ contenant en fonction du code déchet

      $("#ebsdd_dechet_conditionnement").val(contenants[denomination]).trigger('change')

      # Ajax pour trouver la destination associée à la sélection
      #$("#ebsdd_productable_attributes_id").val(denomination)
      url = '/destinations/find_by_nomenclature/' + denomination + '.js'
      $.get( url)

    # Ajoute un onClick listner qui crée une nouvelle plaque d'immatriculation
    $("#add-immatriculation").on 'click', (evt) ->
      plaque = $("#immatriculation-new").val()
      if plaque.length
        url = "/immatriculation/#{ plaque }.json"
        $.post(url).done(addPlaqueImmat)

    # Si la plaque d'immatriculation a bien été crée, on met à jour le champ ebsdd_immatriculation
    addPlaqueImmat = (data, success) ->
      unless jQuery.isEmptyObject(data)
        alert "La plaque d'immatriculation " + data.valeur + " a bien été créée"
        option = '<option value="' + data.id + '">' + data.valeur + "</option>"
        $('#ebsdd_immatriculation').prepend( option )
        $('#ebsdd_immatriculation').val(data.id)
        $('#ebsdd_immatriculation').trigger('change')


    # affiche une erreur en cas d'erreur du webservice
    error = ->
      alert "Impossible de récupérer les données depuis le serveur. Veuillez recommencer, ou recharger la page si l'erreur persiste."

    # remet à zéro les éléments xxxx_siret, xxxx_nom ...
    reset = (elem)->
      attributes = "responsable siret nom adresse ville cp tel fax email".split(' ')
      for attr in attributes
        $("##{elem}_#{attr}").val("")

    # Met à jour les attributs du selecteur 'tag' passé en paramètre
    updateElementInfoAttributes = (data, success, tag) ->
      attributes = "responsable siret nom adresse ville cp tel fax email".split(' ')
      for attr in attributes
        val = data[attr]
        $("##{tag.elem}_#{attr}").val(val)

    # Ajoute un onChange listener au paramètre tag.
    # Le listener fait appel au webservice spécifié par le paramètre url
    # en cas de succès on execute updateElementInfoAttributes avec en paramètre le
    # nom du selecteur à mettre à jour
    addOnChangeHandler = (tag, url) ->
      $("#ebsdd_#{ tag }_id").on 'change', {'tag': tag, 'url': url}, (e) ->
        #data = e.data
        id = $(this).val()
        url = "/#{ e.data.url }/#{id}.json"
        #elem = data.tag
        elem = e.data.tag
        if id == ""
          reset(e.data.tag)
        else
          $.get(url).done((data, success) -> updateElementInfoAttributes(data, success, {'elem':elem})).fail(error)

    # on ajoute un onchange handler pour les elements #ebsdd_xxx_id, afin d'afficher
    # les données associées (nom, siret, email...)récupérées via webservice
    for tag, url of { "destinataire" : "destinataires", "productable" : "producteurs" }
      addOnChangeHandler(tag, url)

    # on affiche les données par défaut pour le producteur en cas d'édition
    initProductable = ->
      id = $("#ebsdd_productable_id option:selected").val()
      url = "/producteurs/#{id}.json"
      $.get(url).done((data, success) -> updateElementInfoAttributes(data, success, {'elem': "productable"})).fail(error) if(id != "")
    initProductable()

    $("#ebsdd_productable_id").on 'change', (e) ->
      $("#ebsdd_emetteur_nom").val $("#ebsdd_productable_id option:selected").text()
