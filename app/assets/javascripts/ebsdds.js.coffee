jQuery ->
  $('.datepicker').datepicker
    defaultDate: "+1w"
    numberOfMonths: 3
    dateFormat: 'dd-mm-yy'
    $.datepicker.regional[ "fr" ]
  $("td.touletip").tooltip(container: "body")
  $("th.touletip").tooltip(container: "body")

  # Enable / Disable $(".disabled")
  disable = (x) ->
    $(".disabled").each ->
      $(this).prop('disabled', x) unless $(this).val() == ""
  disable( true ) if $('.disabled').length
  if $("#import_btn").length
    #$("button#import_btn").button()
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

      console.log "Content loaded..."

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

    if $("#ebsdd_collectable_id option:selected").text() == 'TRIALP'
      $("#immatriculations").show()
    else
      $("#immatriculations").hide()
    #$("#ebsdd_emetteur_nom").val $("#ebsdd_collectable_id option:selected").text()
    $("#ebsdd_emetteur_nom").val $("#ebsdd_productable_id option:selected").text()

    #$("#e1").select2()
    $("#ebsdd_collectable_id").select2
      width: 1076

    $("#ebsdd_productable_id").select2
      width: 507

    $("#ebsdd_destination_id").select2
      width: 339

    $("#ebsdd_immatriculation").select2
      width: 707

    $("#ebsdd_dechet_denomination").select2
      width: 339

    #$("#ebsdd_destination_id").select2
      #width: 507

    # On affiche le formulaire des immatriculations quand le collecteur sélectionné est TRIALP
    $("#ebsdd_collectable_id").on 'change', (e) ->
      if $("#ebsdd_collectable_id option:selected").text() == 'TRIALP'
        $("#immatriculations").show()
      else
        $("#immatriculations").hide()

    # Envoie une requête au serveur pour afficher les info du productable choisi
    $("#ebsdd_productable_id").on 'change', (e) ->
      val =  $(this).val()
      #$("#ebsdd_productable_attributes_id").val(val)
      $("#ebsdd_emetteur_nom").val $("#ebsdd_productable_id option:selected").text()
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

      # Ajax pour trouver la destination associée à la sélection
      #$("#ebsdd_productable_attributes_id").val(denomination)
      url = '/destinations/find_by_nomenclature/' + denomination + '.js'
      $.get( url)

    # Ajoute une plaque d'immatriculation
    $("#add-immatriculation").on 'click', (evt) ->
      plaque = $("#immatriculation-new").val()
      if plaque.length
        $.ajax
          type: 'POST',
          url: '/immatriculation/' + plaque,
          dataType: 'json',
          success: (data) ->
            unless jQuery.isEmptyObject(data)
              alert "La plaque d'immatriculation " + data.valeur + " a bien été créée"
              option = '<option value="' + data.id + '">' + data.valeur + "</option>"
              $('#ebsdd_immatriculation').prepend( option )
              $('#ebsdd_immatriculation').val(data.id)
#$( document).ajaxComplete ->
  #console.log "AjaxCompleted!!!"
  #$("input#search_date_min").addClass("hasDatepicker")
  #$("#search_date_max").addClass("hasDatepicker")
  #$("#search_date").addClass("hasDatepicker")
  #console.log $("#search_date").attr('class')
  #$("body").append('<div id="ui-datepicker-div" class="ui-datepicker ui-widget ui-widget-content ui-helper-clearfix ui-corner-all ui-datepicker-multi ui-datepicker-multi-3" style="position: fixed; top: 166px; left: 683.5px; z-index: 1051; display: none; width: 51em;"><div class="ui-datepicker-group ui-datepicker-group-first"><div class="ui-datepicker-header ui-widget-header ui-helper-clearfix ui-corner-left"><a class="ui-datepicker-prev ui-corner-all" data-handler="prev" data-event="click" title="Précédent"><span class="ui-icon ui-icon-circle-triangle-w">Précédent</span></a><div class="ui-datepicker-title"><span class="ui-datepicker-month">janvier</span>&nbsp;<span class="ui-datepicker-year">2014</span></div></div><table class="ui-datepicker-calendar"><thead><tr><th><span title="lundi">L</span></th><th><span title="mardi">M</span></th><th><span title="mercredi">M</span></th><th><span title="jeudi">J</span></th><th><span title="vendredi">V</span></th><th class="ui-datepicker-week-end"><span title="samedi">S</span></th><th class="ui-datepicker-week-end"><span title="dimanche">D</span></th></tr></thead><tbody><tr><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">1</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">2</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">3</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">4</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">5</a></td></tr><tr><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">6</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">7</a></td><td class="  ui-datepicker-current-day ui-datepicker-today" data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default ui-state-highlight ui-state-active" href="#">8</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">9</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">10</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">11</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">12</a></td></tr><tr><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">13</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">14</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">15</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">16</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">17</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">18</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">19</a></td></tr><tr><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">20</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">21</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">22</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">23</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">24</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">25</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">26</a></td></tr><tr><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">27</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">28</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">29</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">30</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="0" data-year="2014"><a class="ui-state-default" href="#">31</a></td><td class=" ui-datepicker-week-end ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-week-end ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td></tr></tbody></table></div><div class="ui-datepicker-group ui-datepicker-group-middle"><div class="ui-datepicker-header ui-widget-header ui-helper-clearfix"><div class="ui-datepicker-title"><span class="ui-datepicker-month">février</span>&nbsp;<span class="ui-datepicker-year">2014</span></div></div><table class="ui-datepicker-calendar"><thead><tr><th><span title="lundi">L</span></th><th><span title="mardi">M</span></th><th><span title="mercredi">M</span></th><th><span title="jeudi">J</span></th><th><span title="vendredi">V</span></th><th class="ui-datepicker-week-end"><span title="samedi">S</span></th><th class="ui-datepicker-week-end"><span title="dimanche">D</span></th></tr></thead><tbody><tr><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">1</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">2</a></td></tr><tr><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">3</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">4</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">5</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">6</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">7</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">8</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">9</a></td></tr><tr><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">10</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">11</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">12</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">13</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">14</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">15</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">16</a></td></tr><tr><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">17</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">18</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">19</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">20</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">21</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">22</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">23</a></td></tr><tr><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">24</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">25</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">26</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">27</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="1" data-year="2014"><a class="ui-state-default" href="#">28</a></td><td class=" ui-datepicker-week-end ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-week-end ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td></tr></tbody></table></div><div class="ui-datepicker-group ui-datepicker-group-last"><div class="ui-datepicker-header ui-widget-header ui-helper-clearfix ui-corner-right"><a class="ui-datepicker-next ui-corner-all" data-handler="next" data-event="click" title="Suivant"><span class="ui-icon ui-icon-circle-triangle-e">Suivant</span></a><div class="ui-datepicker-title"><span class="ui-datepicker-month">mars</span>&nbsp;<span class="ui-datepicker-year">2014</span></div></div><table class="ui-datepicker-calendar"><thead><tr><th><span title="lundi">L</span></th><th><span title="mardi">M</span></th><th><span title="mercredi">M</span></th><th><span title="jeudi">J</span></th><th><span title="vendredi">V</span></th><th class="ui-datepicker-week-end"><span title="samedi">S</span></th><th class="ui-datepicker-week-end"><span title="dimanche">D</span></th></tr></thead><tbody><tr><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">1</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">2</a></td></tr><tr><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">3</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">4</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">5</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">6</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">7</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">8</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">9</a></td></tr><tr><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">10</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">11</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">12</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">13</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">14</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">15</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">16</a></td></tr><tr><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">17</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">18</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">19</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">20</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">21</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">22</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">23</a></td></tr><tr><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">24</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">25</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">26</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">27</a></td><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">28</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">29</a></td><td class=" ui-datepicker-week-end " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">30</a></td></tr><tr><td class=" " data-handler="selectDay" data-event="click" data-month="2" data-year="2014"><a class="ui-state-default" href="#">31</a></td><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-week-end ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td><td class=" ui-datepicker-week-end ui-datepicker-other-month ui-datepicker-unselectable ui-state-disabled">&nbsp;</td></tr></tbody></table></div><div class="ui-datepicker-row-break"></div></div>')

