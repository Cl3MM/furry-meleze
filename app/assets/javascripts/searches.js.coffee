# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
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

