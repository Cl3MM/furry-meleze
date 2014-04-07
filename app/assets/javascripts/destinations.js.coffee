# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


jQuery ->
  $("#destination_nomenclatures").select2(tags: $("#destination_nomenclatures").val(), width: 906, allowClear: true, placeholder: "Ajouter les nomemnclatures de déchets...")

  console.log $("#destination_nomenclatures").val()
