# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


jQuery ->
  $("#produit_references").select2
    tags: $("#produit_references").val()
    width: 524
    allowClear: true
    placeholder: "Ajouter les références du produit..."
    tokenSeparators: [",", " ", ";"]
