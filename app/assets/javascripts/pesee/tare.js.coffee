root = exports ? this

# Tare class
class Tare
  constructor: (data) ->
    ko.mapping.fromJS(data, {}, @)
    @designation = ko.pureComputed( =>
      "#{@nom()} - #{@poids()} kg"
    ,@)
    @pretty_poids = ko.pureComputed( =>
      "#{@poids().toFixed(2)}".replace(".",",") + ' kg'
    ,@)

unless root.Tare
  root.Tare = Tare

