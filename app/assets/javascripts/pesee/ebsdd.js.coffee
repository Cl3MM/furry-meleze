root = exports ? this

# Ebsdd class
class Ebsdd
  constructor: (data) ->
    ko.mapping.fromJS(data, {}, @)

unless root.Ebsdd
  root.Ebsdd = Ebsdd

