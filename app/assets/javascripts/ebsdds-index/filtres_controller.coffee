root = exports ? this

class FiltresController
  constructor: () ->
    #ko.mapping.fromJS(data, {}, @)
    @status   = $("#model").data("status")
    @par      = ['Producteur', 'Ebsdds', 'Ecodds']
    @critere  = ko.observable('Producteur')
    @query    = ko.observable('').extend rateLimit: 750
    @results  = ko.observableArray []
    @loading  = ko.observable false
    @query.subscribe @find
    @critere.subscribe @find
    $("#filtered").hide().removeClass('hidden')

  find: =>
    if @query().length is 0
      $("#unfiltered").fadeIn(200)
      $("#filtered").fadeOut 200
      $("#pagination").fadeIn 200
      return
    $("#unfiltered").fadeOut 200
    $("#pagination").fadeOut 200
    $("#filtered").fadeIn 200
    @loading true
    $.get "/ebsdds/filter/#{@status}/#{@critere().toLowerCase()}/#{@query()}"
      .done @displayResponse
      .fail @failed
  resetMe: =>
    @query('')
    return

  displayResponse: (data)=>
    @results data.data
    @loading false

  failed: =>
    @loading false

  formatDate: (date)->
    moment(date, "YYYY-MM-DD").format("DD/MM/YYYY")

  formatPoids: (pds)->
    #bordereau_poids
    return "-" unless pds
    "#{pds.toFixed(2).replace('.',',')} kg"

unless root.FiltresController
  root.FiltresController = FiltresController
