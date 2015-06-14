root = exports ? this

class SortiesController
  constructor: () ->
    @stats = $("#sorties").data "stats"
    @du = moment().subtract(1, 'week').startOf 'week'
    @au = moment().subtract(1, 'week').endOf 'week'
    ko.track @, deep: true

  find: ->
    $.get "/statistiques/quantites_sorties/#{@du.format("DD-MM-YYYY")}/#{@au.format("DD-MM-YYYY")}"
    .done (data)=>
      console.log data
      @stats = data

unless root.SortiesController
  root.SortiesController = SortiesController

