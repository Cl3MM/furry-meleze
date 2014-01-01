jQuery ->
  console.log 'coucou'
  producteur = $.parseJSON '<%= raw( j @producteur.to_json ) %>'
  attributes = $.parseJSON '<%= raw %w( siret responsable adresse ville cp tel fax email ).to_json %>'

  for attr in attributes
    val = producteur[attr]
    dis = if !!val then true else false
    $("#ebsdd_producteur_attributes_#{ attr }").val(val)
    $("#ebsdd_producteur_attributes_#{ attr }").prop('disabled', dis)

  #$("#producteur_info").html "<%#= escape_javascript(render(partial: 'ebsdds/edit/cadre1_producteur_info', object: @producteur, as: :producteur))%>"
  #$(".disabled").each ->
    #$(this).prop('disabled', true) unless $(this).val() == ""
