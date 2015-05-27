jQuery.download = (url, data, method) ->
  authenticityToken = $("meta[name='csrf-token']").attr("content")
  #url and data options required
  if url and data
    #data can be string of parameters or array/object
    data = (if typeof data is "string" then data else jQuery.param(data))
    #split params into form inputs
    inputs = ""
    $.each data.split("&"), ->
      pair = @split("=")
      inputs += "<input type=\"hidden\" name=\"" + pair[0] + "\" value=\"" + pair[1] + "\" />" unless !pair[0]
      return
    #send request
    inputs += '<input name="authenticity_token" type="hidden" value="' + authenticityToken + '">'
    form = "<form action=\"" + url + "\" method=\"" + (method or "post") + "\">" + inputs + "</form>"
    $(form).appendTo("body").submit().remove()

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

  #move_save_button = (original) ->
    #if original
      #$("#save-ebsdd-btn").css(position: 'initial', 'z-index': 1000)
    #else
      #$("#save-ebsdd-btn").hide()
      #w = (parseInt $("body .container").css("margin-right").replace("px", "") - $("#save-ebsdd-btn").width() ) / 2
      #$("#save-ebsdd-btn").css(position: 'fixed', bottom: 20, right: w, 'z-index': 1000).show()

  buttonBarRightMargin = () ->
    rightMargin = parseInt($("body .container").css("margin-right").replace("px", ""))
    bttw = $("#button-bar").width()
    rightMargin + bttw
  $("#save-ebsdd-btn").on 'click', (e)->
    $(this).prop("disabled", true)
    $(this).find("i.fa-save").removeClass("fa-save").addClass("fa-spin fa-spinner")
    $(this).submit()
    $(".panel-body > form").submit()

  display_back_to_top_arrow = () ->
    $("#floating-save").tooltip()
    $("#floating-save").on 'click', (e) ->
      $(this).prop("disabled", true)
      $(this).find("i.fa-save").removeClass("fa-save").addClass("fa-spin fa-spinner")
      $(".panel-body > form").submit()

    $("#button-bar").css
      "position": "fixed",
      "bottom": 15,
      "right": buttonBarRightMargin()

    $(window).on 'resize', (e) ->
      $('#button-bar').css right: buttonBarRightMargin()
    $(window).scroll ->
      if $(this).scrollTop() > 100
        $("#button-bar").slideDown()
      else
        $("#button-bar").slideUp()
      return

    # scroll body to 0px on click
    $("#button-bar a").click ->
      $("body,html").animate
        scrollTop: 0
      , 500
      false

  display_back_to_top_arrow() if $("#button-bar")

  if $("#edit").length
    if $("#ebsdd_dechet_nombre_colis").val() == ""
      $("#ebsdd_dechet_nombre_colis").val(1)

    if $("#ebsdd_collecteur_id option:selected").text() == 'TRIALP'
      $("#immatriculations").show()
    else
      $("#immatriculations").hide()
    #$("#ebsdd_emetteur_nom").val $("#ebsdd_collecteur_id option:selected").text()
    $("#ebsdd_emetteur_nom").val $("#ebsdd_producteur_id option:selected").text()


    # éléments auxquel on va ajouter Select2 (le chiffre représente la largeur)
    toSelect = {
      1076 : [ "collecteur_id" ],
      707  : [ "immatriculation", "dechet_conditionnement" ],
      507  : [ "producteur_id", "destinataire_id" ],
      #339  : [ "destination_id", "super_denomination" ],
    }
    # On parcourt le dictionaire ci dessus et on ajoute select2 à tous les éléments
    for len, arr of toSelect
      for selector in arr
        $("#ebsdd_#{ selector }").select2( containerCssClass: "form-control" )

    # On affiche le formulaire des immatriculations quand le collecteur sélectionné est TRIALP
    $("#ebsdd_collecteur_id").on 'change', (e) ->
      if $("#ebsdd_collecteur_id option:selected").text() == 'TRIALP'
        $("#immatriculations").show()
      else
        $("#immatriculations").hide()

    # Envoie une requête au serveur pour afficher les info du producteur choisi
    #$("#ebsdd_producteur_id").on 'change', (e) ->
      #val =  $(this).val()
      ##$("#ebsdd_producteur_attributes_id").val(val)
      #$("#ebsdd_emetteur_nom").val $("#ebsdd_producteur_id option:selected").text()
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
      #$("#ebsdd_produit_id").val denomination

    # Set default value for hidden field to avoid errors
    if $("#ebsdd_produit_id").length and $("input#ebsdd_dechet_nomenclature").length
      $("input#ebsdd_dechet_nomenclature").val( $("#ebsdd_produit_id").val() )
      $("#ebsdd_valorisation_prevue").val($("#ebsdd_code_operation").val())

    # S'il y a une erreur dans la désignation, le msg est affiché 2 fois.
    # Du coup on cache un des deux messages
    if $("input#ebsdd_dechet_nomenclature").prev().prop('class') == " text-danger" and $("input#ebsdd_dechet_nomenclature").next().prop('class') == " text-danger"
      $("input#ebsdd_dechet_nomenclature").next().hide()

    # Code D/R Cadre 11 = Code D/R Cadre 2 (Valespace, R13)
    # $("#ebsdd_code_operation").val( $("#ebsdd_valorisation_prevue").val())

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


    ## MEGA TEST pour les produits
    # {id: 2, label: "Emballages Vides Souillés (Evs)", cr: "150110", dr11: "R13", dr12: "R1"…}
    db = $("#dechets").data("data")

    $("#ebsdd_produit_id").on 'change', (evt) ->
      denomination = $(this).val()
      denominationInt = $(this).val()
      for l in db
        if l.id == denominationInt
          $("#code_rubrique_dechet").html("#{ l.cr }*")
          $("select#ebsdd_dechet_nomenclature").val(l.id)
          # On met la valeur sélectionnée dans le champ hidden car l'attribut disabled du select empeche la validation coté serveur
          $("input#ebsdd_dechet_nomenclature").val(l.cr)

          # consistance
          $("#ebsdd_dechet_consistance_0").prop("checked", true) if l.c6tnc == 0
          $("#ebsdd_dechet_consistance_1").prop("checked", true) if l.c6tnc == 1
          $("#ebsdd_dechet_consistance_2").prop("checked", true) if l.c6tnc == 2
          # Cadre 11
          $("#ebsdd_code_operation").val(l.dr11)
          # Cadre 2
          $("#ebsdd_valorisation_prevue").val(l.dr11)
          $("#ebsdd_destination_id option").each (e) ->
            if $(this).text() == l.dest
              $("#ebsdd_destination_id").val($(this).val()).trigger('change')
              $("#ebsdd_traitement_prevu").val("D13").trigger('change')
          boite = contenants[l.cr]
          $("#ebsdd_dechet_conditionnement").select2('val', boite ) #.trigger('change')

      # Remplis le champ contenant en fonction du code déchet

      # Cadre 5
      # $("#ebsdd_dechet_conditionnement").val(contenants[l.cr]).trigger('change')

      # Ajax pour trouver la destination associée à la sélection
      #$("#ebsdd_producteur_attributes_id").val(denomination)
      url = '/destinations/find_by_nomenclature/' + denomination + '.js'
      $.get( url)


    # Change le code rubrique dechet et la mention au titre des reglnt en fonction du champ dechet denomination usuelle
    #$("#ebsdd_produit_id").on 'change', (evt) ->
      #denomination = $(this).val()
      #$("#code_rubrique_dechet").html("#{ denomination }*")
      #$("select#ebsdd_dechet_nomenclature").val(denomination)
      ## On met la valeur sélectionnée dans le champ hidden car l'attribut disabled du select empeche la validation coté serveur
      #$("input#ebsdd_dechet_nomenclature").val(denomination)
      #for k, v of destination_configuration
        #if k == denomination
          #$("#ebsdd_destination_id option").each (e) ->
            #if $(this).text() == v[1]
              #$("#ebsdd_destination_id").val($(this).val()).trigger('change')
              #$("#ebsdd_traitement_prevu").val(v[0]).trigger('change')
      ## Remplis le champ contenant en fonction du code déchet

      #$("#ebsdd_dechet_conditionnement").val(contenants[denomination]).trigger('change')

      ## Ajax pour trouver la destination associée à la sélection
      ##$("#ebsdd_producteur_attributes_id").val(denomination)
      #url = '/destinations/find_by_nomenclature/' + denomination + '.js'
      #$.get( url)

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
    for tag, url of { "destinataire" : "destinataires", "producteur" : "producteurs" }
      # Fucking CLOSURE !!!! We have to scope thanks to thd "do" keyword we end up with the same value passed on to every call...
      do(tag, url) ->
        addOnChangeHandler(tag, url)
        # on affiche les données par défaut pour le producteur en cas d'édition
        id = $("#ebsdd_#{ tag }_id option:selected").val()
        url = "/#{ url }/#{id}.json"
        prout = tag
        $.get(url).done((data, success) -> updateElementInfoAttributes(data, success, {'elem': "#{tag}" })).fail(error) if(id != "")

    compare = (a,b)->
      return -1 if a.text < b.text
      return 1 if a.text > b.text
      return 0

    # initialisation de la liste des produits
    initDenomination = () ->
      data = []
      #data.push {text: l.label, id: l.id} for l in db
      val = $("#ebsdd_producteur_id").select2('data').text
      for l in db
        if !!val.match(/ECO ?DDS/gi)
          data.push {text: l.label, id: l.id} if l.is_ecodds == true
        else
          data.push {text: l.label, id: l.id} if l.is_ecodds == false

      $("#ebsdd_produit_id").select2(data: data.sort(compare), width: 339, placeholder: "Sélectionnez une dénomination..." )

    initDenomination()

    $("#ebsdd_producteur_id").on 'change', (e) ->
      $("#ebsdd_emetteur_nom").val $("#ebsdd_producteur_id option:selected").text()
      val = $(this).select2('data').text
      data = []
      for l in db
        if !!val.match(/ECO ?DDS/gi)
          data.push {text: l.label, id: l.id} if l.is_ecodds == true
        else
          data.push {text: l.label, id: l.id} if l.is_ecodds == false
      $("#ebsdd_produit_id").select2(data: data)

    # Split d'un ebsdd
    $("#split-ebsdd").on 'click', (e)->
      action = $("form.edit_ebsdd").prop("action")
      $("form.edit_ebsdd").prop("action", action + '/split').submit()


  # Traitement des nouveaux BSDs
  $("#nouveaux_pdfs").on 'click', (e) ->
    e.preventDefault()
    if $("#master_nouveau_pdf_checkbox").length
      $(".toggle_nv_pdf").toggle()
      return
    thead = $(".panel .panel-body table thead tr").first()
    thead.prepend('<td class="toggle_nv_pdf"><input id="master_nouveau_pdf_checkbox" type="checkbox"></td>')

    tbody = $(".panel .panel-body table tbody").first()
    tdCounts = $(".panel .panel-body table tbody tr:first td").length + 1
    $(".panel .panel-body table tbody tr").each (e) ->
      $(this).prepend('<td class="toggle_nv_pdf"><input type="checkbox" class="nouveau_pdf"></td>')


    status = $("#ebsdds").data("status")

    tag = "<tr><td class='toggle_nv_pdf' colspan='#{ tdCounts }'>"
    if status == "en_attente"
      tag += "<a href='#' id='changeNouveauStatus' class='btn btn-primary btn-sm'><i class='fa fa-truck'></i> Mettre en Stock</a>"
    else
      tag +=  "<a href='#' id='export_nv_bsds' class='btn btn-primary btn-sm'><i class='fa fa-file'></i>imprimer les BSD sélectionnés</a>&nbsp;"
      tag += "<a href='#' id='changeNouveauStatus' class='pull-right btn btn-primary btn-sm'><i class='fa fa-truck'></i> Prêt pour la collecte</a>"

    tag += "</td></tr>"
    tbody.append(tag)

    $("#changeNouveauStatus").on 'click', (e) ->
      e.preventDefault()
      ids = []
      $(".nouveau_pdf").each (i) ->
        ids.push $(this).closest('tr').prop('id') if $(this).prop('checked')
      $("#changeNouveauStatus").prop('disabled', true)
      $("#changeNouveauStatus i").removeClass("fa-file").addClass("fa-spin fa-spinner")
      status = $("#ebsdds").data("status")
      if status == "en_attente"
        url = "/ebsdds/change_en_attente_statut.json"
      else
        url = "/ebsdds/change_nouveau_statut.json"
      $.post(url, { ids: ids }).done( nouveauStatusChanged )

    nouveauStatusChanged = (d,s) ->
      $("#changeNouveauStatus i").removeClass("fa-spin fa-spinner").addClass("fa-file")
      console.log d
      unless d.err is undefined
        div = "<div class='alert alert-danger'>Veuillez remplir les poids des ebbsdd suivants : #{d.err.join(', ')}</div>"
        $(div).insertAfter($("body .container .navbar")).fadeIn(600).delay(2000).fadeOut(600)
      ids = d.data
      for id in ids
        $("##{id}").closest('tr').fadeOut(600, removeNouveauTr)
        #$(".nouveau_pdf").each (i) ->
          #_id = $(this).closest('td').next().text().replace( /( )/g, "")
          #if _id == id
            #$(this).closest('tr').fadeOut(600, removeNouveauTr)

    removeNouveauTr = ()->
      $(this).remove()
      if tbody.find('tr').length == 1 and $(".toggle_nv_pdf").length
        div = '<div class="alert alert-info">Plus aucun BSD à traiter.</div>'
        $(".panel .panel-body table").fadeOut(600).replaceWith(div)

    $("#export_nv_bsds").on 'click', (e) ->
      e.preventDefault()
      ids = []
      $(".nouveau_pdf").each (i) ->
        if $(this).prop('checked')
          #id = $(this).closest('td').next().text()
          #id = id.replace(/( )/g, "")
          id = $(this).closest('tr').prop('id')
          ids.push id
      $("#export_nv_bsds").prop('disabled', true)
      $("#export_nv_bsds i").removeClass("fa-file").addClass("fa-spin fa-spinner")
      #$.get("/ebsdds/nouveaux_pdfs", { ids: ids}).done(nvPdfDone).fail(nvPdfFail)
      params = ""
      params += "ids[]=#{ids[i]}&" for i in [0..ids.length-1]
      $.download("/ebsdds/nouveaux_pdfs", params, 'post')
      setTimeout nvPdfDone, 1000

    nvPdfFail = (d,s) ->
      console.log d
    nvPdfDone = () ->
      $("#export_nv_bsds").prop('disabled', false)
      $("#export_nv_bsds i").removeClass("fa-spin fa-spinner").addClass("fa-file")

    $("#master_nouveau_pdf_checkbox").on 'change', (e) ->
      $(".panel .panel-body table tbody tr .nouveau_pdf").each (c) ->
        checked = $(this).prop('checked')
        $(this).prop('checked', !checked)

  # bouton nouveau status (passe le status de Nouveau à En Attente)
  $("body").on 'click', '.nouveau_statut', (e) ->
    e.preventDefault()
    #selector = if $("#master_nouveau_pdf_checkbox").length then 'nth-child(2)' else 'first-child'
    #id = $(this).closest('tr').find("td:#{selector}").text()
    #id = id.replace /( )/g, ""
    id = $(this).closest('tr').prop('id')
    url = "/ebsdd/#{id}/change_nouveau_statut.json"
    $.post(url).done(fadeNvEbsdd).fail( ( (d,s)-> console.log d ) )

  fadeNvEbsdd = (d,s) ->
    id = d.id
    $("##{id}").fadeOut(700, removeNouveauEbsdd)
    #selector = if $("#master_nouveau_pdf_checkbox").length then 'nth-child(2)' else 'first-child'
    #$(".panel .panel-body table tbody tr td:#{selector}").each (e) ->
      #_id = $(this).text().replace(/( )/g, "")
      #if _id == id
        #console.log $(this).closest('tr')
        #$(this).closest('tr').fadeOut(700, removeNouveauEbsdd)

  removeNouveauEbsdd = (e) ->
    $(this).remove()
    if $(".panel .panel-body table tbody tr").length == 0
      location.reload
      div = '<div class="alert alert-info">Plus aucun BSD à traiter.</div>'
      $(".panel .panel-body table").fadeOut(600).replaceWith(div)

  $("#ebsdd_bordereau_date_transport").on "change", (e)->
    $("#ebsdd_bordereau_date_reception").val $(this).val()

  # bouton en attente status (passe le status de En Attente à Pret à sortir)
  $("body").on 'click', ".en_attente_statut", (e) ->
    e.preventDefault()
    elem = $(this).first().closest('tr').find(".poids")
    data = elem.data('cdt')
    poids = elem.text().trim()
    err = []
    if poids == "-" or parseFloat( poids.replace(" kg", "") ) == 0
      err.push "Veuillez remplir le poids de l'ebbsdd avant de changer le statut."
    err.push "Veuillez remplir le conditionnement avant de mettre cet eBsdd en attente" unless data

    if err.length > 0
      msg = ("<p>#{e}</p>" for e in err)
      div = "<div class='alert alert-danger'>#{msg.join("")}</div>"
      $(div).insertAfter($("body .container .navbar")).fadeIn(600).delay(2000).fadeOut(600)
      return false
    id = $(this).closest('tr').prop('id')
    url = "/ebsdd/#{id}/change_en_attente_statut.json"
    $.post(url).done(fadeNvEbsdd).fail( ( (d,s)-> console.log d ) )

  removeNouveauEbsdd = (e) ->
    $(this).remove()
    if $(".panel .panel-body table tbody tr").length == 0
      div = '<div class="alert alert-info">Plus aucun BSD à traiter.</div>'
      $(".panel .panel-body table").fadeOut(600).replaceWith(div)

  # vérification du champ poids pour permettre le téléchargment du bsd
  $(".check-poids").on 'click', (e) ->
    if $(this).first().closest('td').prev().text().trim() == "-"
      div = "<div class='alert alert-danger'>Veuillez remplir le bsd avant d'imprimer le Cerfa.</div>"
      $(div).insertAfter($("body .container .navbar")).fadeIn(600).delay(2000).fadeOut(600)
      e.preventDefault()
      return false

  if $("#new").length > 0 and $("#ebsdd_traitement_prevu").length > 0
    $("#ebsdd_traitement_prevu").val("D13" ).trigger('change')

