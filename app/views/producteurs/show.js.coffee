jQuery ->
  producteur = $.parseJSON '<%= raw( j @producteur.to_json ) %>'
  attributes = $.parseJSON '<%= raw %w( siret responsable adresse ville cp tel fax email ).to_json %>'

  # If calling action is edit, we set a prefix
  prefix = if not $("#new_producteur").length then "ebsdd_productable_attributes_" else "" 

  for attr in attributes
    val = producteur[attr]
    #dis = if !!val then true else false
    $("##{ prefix }#{ attr }").val(val)
    $("##{ prefix }#{ attr }").prop('disabled', true)

  #for attr in attributes
    #val = producteur[attr]
    #dis = if !!val then true else false
    #$("#ebsdd_productable_attributes_#{ attr }").val(val)
    #$("#ebsdd_productable_attributes_#{ attr }").prop('disabled', dis)

  #$("#producteur_info").html "<%#= escape_javascript(render(partial: 'ebsdds/edit/cadre1_producteur_info', object: @producteur, as: :producteur))%>"
  #$(".disabled").each ->
    #$(this).prop('disabled', true) unless $(this).val() == ""
