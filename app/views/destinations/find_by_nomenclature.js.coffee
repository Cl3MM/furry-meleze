jQuery ->
  collecteur = $.parseJSON '<%= raw( j @collecteur.to_json ) %>'
  console.log collecteur
  attributes = $.parseJSON '<%= raw %w( siret responsable adresse ville cp tel fax email ).to_json %>'

  for attr in attributes
    val = collecteur[attr]
    dis = if !!val then true else false
    $("#ebsdd_collecteur_attributes_#{ attr }").val(val)
    $("#ebsdd_collecteur_attributes_#{ attr }").prop('disabled', dis)
