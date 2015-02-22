# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->

  getFormattedDate = (date) ->
    year = date.getFullYear()
    month = (1 + date.getMonth()).toString()
    month = if month.length > 1 then month else '0' + month
    day = date.getDate().toString()
    day = if day.length > 1 then day else '0' + day
    day + '/' + month + '/' + year


  # alertes
  $("#collapseOne").on 'hide.bs.collapse', () ->
    $("#alertes").empty()

  $("#collapseOne").on 'shown.bs.collapse', () ->
    rawData = $("#alertes").data("alertes")
    data = for i in rawData
      { y: i.nom, a: i.poids, b: i.seuil }

    Morris.Bar
      element: 'alertes',
      data: data
      xkey: 'y',
      ykeys: ['a', 'b'],
      labels: ['Poids en stock', 'Seuil maximal']
      barColors: ["#FF0000","#666"]
      hideHover: 'auto'

  # camions
  $("#collapseTwo").on 'hide.bs.collapse', () ->
    $("#camions").empty()

  $("#collapseTwo").on 'shown.bs.collapse', () ->
    initCamions()

  caRawData = $("#camions").data("camions")
  $("#ca-2-excel").hide() unless caRawData.data.length
  window.ca_csv_dl = 0

  $("#ca-2-excel").on 'click', (e)->
    window.ca_csv_dl += 1

    dateMin = $("#ca-du").text()
    dateMax = $("#ca-au").text()

    console.log dateMin
    console.log dateMax

    $(this).prop("href", $(this).prop("href").split(".csv?")[0] + ".csv") if window.ca_csv_dl > 1
    url = $(this).prop("href")
    url += "?date_min=#{dateMin}&date_max=#{dateMax}"
    $(this).prop("href", url )

  initCamions = (e)->
    $("#camions").empty()
    rawData = []
    if e == undefined
      rawData = $("#camions").data("camions")
    else
      rawData = e
    $("#ca-du").text rawData.du
    $("#ca-au").text rawData.au

    $("#ca-date-min").val("")
    $("#ca-date-max").val("")
    $("#ca-date-min").prop "placeholder", rawData.du
    $("#ca-date-max").prop "placeholder", rawData.au

    data = for i in rawData.data
      { y: i.nom, a: i.poids }

    $("#camions-table tbody").html("")
    if !data.length
      console.log "pas de données"
      $("#camions").html("")
      $("#camions-table").fadeOut(200)
      $("#camions-table tbody").html("")
      err = $('<div class="alert alert-info">Aucune donnée à ces dates.</div>')
      err.hide()
      $("#camions").append(err)
      err.fadeIn(600)
      $("#ca-2-excel").hide()
    else
      $("#ca-2-excel").show()
      $("#camions-table").fadeIn(200)
      trs = ""
      for i in data
        trs += "<tr>
                <td>#{i.y}</td>
                <td>#{i.a}</td>
              </tr>"
      $("#camions-table tbody").append(trs)
      Morris.Bar
        element: 'camions',
        data: data
        xkey: 'y',
        ykeys: ['a'],
        labels: ['Poids en tonne']
        barColors: ["#444", "#FF0000"]
        hideHover: 'auto'

  initCamions()

  $("#ca-date-min").datepicker
    defaultDate: "+1w"
    numberOfMonths: 1
    dateFormat: 'dd-mm-yy'
    onClose: (selectedDate) ->
      $("#ca-date-max").datepicker "option", "minDate", selectedDate
      $("#ca-date-max").datepicker('show')
    $.datepicker.regional[ "fr" ]

  $("#ca-date-max").datepicker
    defaultDate: "+1w"
    numberOfMonths: 1
    dateFormat: 'dd-mm-yy'
    onClose: (selectedDate) ->
      $("#ca-date-min").datepicker "option", "maxDate", selectedDate
    $.datepicker.regional[ "fr" ]


  $("#ca-show").on 'click', (e)->
    e.preventDefault()
    dateMin = $("#ca-date-min").val()
    dateMax = $("#ca-date-max").val()
    if !!dateMin && !!dateMax
      url = $(this).closest('form').prop('action')
      $.post(url, {date_min: dateMin, date_max: dateMax}).done(initCamions)


  # Destinations Ultérieures
  deRawData = $("#dest").data("dest")
  $("#dest-2-excel").hide()
  window.de_csv_dl = 0

  $("#dest-2-excel").on 'click', (e)->
    window.de_csv_dl += 1

    destId = $("#dest-select").select2("val")
    dateMin = $("#dest-du").text()
    dateMax = $("#dest-au").text()

    console.log destId
    console.log dateMin
    console.log dateMax

    $(this).prop("href", $(this).prop("href").split(".csv?")[0] + ".csv") if window.de_csv_dl > 1
    url = $(this).prop("href")
    url += "?date_min=#{dateMin}&date_max=#{dateMax}&dest_id=#{destId}"
    $(this).prop("href", url )

  $("#dest-date-min").datepicker
    defaultDate: "+1w"
    numberOfMonths: 1
    dateFormat: 'dd-mm-yy'
    onClose: (selectedDate) ->
      $("#dest-date-max").datepicker "option", "minDate", selectedDate
      $("#dest-date-max").datepicker('show')
    $.datepicker.regional[ "fr" ]

  $("#dest-date-max").datepicker
    defaultDate: "+1w"
    numberOfMonths: 1
    dateFormat: 'dd-mm-yy'
    onClose: (selectedDate) ->
      $("#dest-date-min").datepicker "option", "maxDate", selectedDate
    $.datepicker.regional[ "fr" ]


  displayDestinations = (d)->
    console.log "resultats"
    console.log d
    $("#dest-du").text(d.du)
    $("#dest-au").text(d.au)
    $("#dest-nom").text(d.destination)
    $("#dest-poids-total").text(d.poids_total)
    $("#dest-result").fadeIn(500)
    $("#dest").empty()

    hoverCallback = (index, options, content)->
      row = options.data[index]
      "<div class='morris-hover-row-label'>Jour: #{row.y}</div><div class='morris-hover-point' style='color: #0b62a4'>Poids : #{row.a} tonnes</div>"

    if !d.data.length
      $("#dest-2-excel").hide()
      console.log "pas de données"
      $("#dest").html("")
      err = $('<div class="alert alert-info">Aucune donnée à ces dates.</div>')
      err.hide()
      $("#dest").append(err)
      err.fadeIn(600)
    else
      $("#dest-2-excel").show()
      data = for i in d.data
        { y: i.jour, a: i.poids }
      Morris.Bar
        element: 'dest',
        data: data
        xkey: 'y',
        ykeys: ['a'],
        labels: ['Poids (t)']
        hoverCallback: hoverCallback


  initDest = (e)->
    $("#dest-result").hide()
    dest = $("#dest").data("dest")
    $("#dest-select").select2
      data: dest
      placeholder: "Sélectionnez une destination..."
      allowClear: true

  initDest()

  $("#dest-show").on 'click', (e)->
    e.preventDefault()
    dateMin = $("#dest-date-min").val()
    dateMax = $("#dest-date-max").val()
    dest_id = $("#dest-select").select2("val")
    if !!dateMin && !!dateMax && !!dest_id
      url = $(this).closest('form').prop('action')
      $.post(url, {date_min: dateMin, date_max: dateMax, dest_id: dest_id }).done(displayDestinations)


  # Quantites

  # Initialisation des date des quantites :

  qteRawData = $("#qtes").data("qtes")
  $("#qte-du").text qteRawData.du
  $("#qte-au").text qteRawData.au
  $("#qte-2-excel").hide() unless qteRawData.data.length
  window.csv_dl = 0

  $("#qte-2-excel").on 'click', (e)->
    window.csv_dl += 1

    dateMin = $("#qte-du").text()
    dateMax = $("#qte-au").text()

    $(this).prop("href", $(this).prop("href").split(".csv?")[0] + ".csv") if window.csv_dl > 1
    url = $(this).prop("href")
    url += "?date_min=#{dateMin}&date_max=#{dateMax}"
    $(this).prop("href", url )

    #e.preventDefault()
    #url = "/statistiques/quantites_to_csv.csv"
    #$.get(url, {date_min: dateMin, date_max: dateMax})

  $("#collapseFour").on 'hide.bs.collapse', () ->
    $("#quantites").empty()

  $("#collapseFour").on 'shown.bs.collapse', () ->
    initQuantites()

  initQuantites = (e)->
    $("#qtes").empty()
    rawData = []
    if e == undefined
      rawData = $("#qtes").data("qtes")
    else
      rawData = e
    $("#qte-du").text rawData.du
    $("#qte-au").text rawData.au

    $("#qte-date-min").val("")
    $("#qte-date-max").val("")
    $("#qte-date-min").prop "placeholder", rawData.du
    $("#qte-date-max").prop "placeholder", rawData.au

    data = for i in rawData.data
      { y: i.nom, a: i.poids }

    $("#qtes-table tbody").html("")
    if !data.length
      console.log "pas de données"
      $("#qte-2-excel").hide()
      $("#qtes").html("")
      $("#qtes-table").fadeOut(200)
      $("#qtes-table tbody").html("")
      err = $('<div class="alert alert-info">Aucune donnée à ces dates.</div>')
      err.hide()
      $("#qtes").append(err)
      err.fadeIn(600)
    else
      $("#qtes-table").fadeIn(200)
      trs = ""
      for i in data
        trs += "<tr>
                <td>#{i.y}</td>
                <td>#{i.a}</td>
              </tr>"
      $("#qtes-table tbody").append(trs)
      $("#qte-2-excel").show()

      Morris.Bar
        element: 'qtes',
        data: data
        xkey: 'y',
        ykeys: ['a'],
        labels: ['Poids en tonne']
        barColors: ["#444", "#FF0000"]
        hideHover: 'auto'

  initQuantites()

  $("#qte-date-min").datepicker
    defaultDate: "+1w"
    numberOfMonths: 1
    dateFormat: 'dd-mm-yy'
    onClose: (selectedDate) ->
      $("#qte-date-max").datepicker "option", "minDate", selectedDate
      $("#qte-date-max").datepicker('show')
    $.datepicker.regional[ "fr" ]

  $("#qte-date-max").datepicker
    defaultDate: "+1w"
    numberOfMonths: 1
    dateFormat: 'dd-mm-yy'
    onClose: (selectedDate) ->
      $("#qte-date-min").datepicker "option", "maxDate", selectedDate
    $.datepicker.regional[ "fr" ]


  $("#qte-show").on 'click', (e)->
    e.preventDefault()
    dateMin = $("#qte-date-min").val()
    dateMax = $("#qte-date-max").val()
    if !!dateMin && !!dateMax
      url = $(this).closest('form').prop('action')
      $.post(url, {date_min: dateMin, date_max: dateMax}).done(initQuantites)



