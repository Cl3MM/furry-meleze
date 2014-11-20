root = exports ? this

# Tare class
class Tare
  constructor: (data) ->
    ko.mapping.fromJS(data, {}, @)
    @designation = ko.pureComputed( =>
      "#{@nom()} - #{@poids()} kg"
    ,@)

unless root.Tare
  root.Tare = Tare

