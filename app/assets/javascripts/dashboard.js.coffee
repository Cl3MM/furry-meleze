# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  if $("#alertes").length
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

