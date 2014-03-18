jQuery ->
  if $("#collecteur").length
    $('.datepicker').datepicker
      defaultDate: "+1w"
      numberOfMonths: 3
      dateFormat: 'dd-mm-yy'
      $.datepicker.regional[ "fr" ]
