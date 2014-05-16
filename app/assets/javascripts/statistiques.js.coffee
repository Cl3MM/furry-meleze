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
      barColors: ["#eee", "#FF0000"]
      hideHover: 'auto'

  $("#collapseTwo").on 'hide.bs.collapse', () ->
    $("#camions").empty()

  $("#collapseTwo").on 'shown.bs.collapse', () ->
    initCamions()

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
    else
      $("#camions-table").fadeIn(200)
      console.log data
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
    console.log d

    $("#dest-du").text(d.du)
    $("#dest-au").text(d.au)
    $("#dest-nom").text(d.destination)
    $("#dest-poids-total").text(d.poids_total)
    $("#dest-result").fadeIn(500)
    $("#dest").empty()

    hoverCallback = (index, options, content)->
      row = options.data[index]
      date = new Date row.y
      dateStr = getFormattedDate date
      "<div class='morris-hover-row-label'>Jour: #{dateStr}</div><div class='morris-hover-point' style='color: #0b62a4'>Poids : #{row.a} tonnes</div>"

    if !d.data.length
      console.log "pas de données"
      $("#dest").html("")
      err = $('<div class="alert alert-info">Aucune donnée à ces dates.</div>')
      err.hide()
      $("#dest").append(err)
      err.fadeIn(600)
    else
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
    console.log dest_id
    if !!dateMin && !!dateMax && !!dest_id
      url = $(this).closest('form').prop('action')
      console.log url
      $.post(url, {date_min: dateMin, date_max: dateMax, dest_id: dest_id }).done(displayDestinations)



