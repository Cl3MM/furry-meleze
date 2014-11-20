root = exports ? this

class Poids
  constructor: (data) ->
    console.log data
    ko.mapping.fromJS(data, {}, @)

  netEnKilo: =>
    "#{parseFloat(@net.val())}".replace(".", ",") + " kg"
  tareEnKilo: =>
    "#{parseFloat(@tare.val())}".replace(".", ",") + " kg"
  brutEnKilo: =>
    "#{parseFloat(@brut.val())}".replace(".", ",") + " kg"

unless root.Poids
  root.Poids = Poids

