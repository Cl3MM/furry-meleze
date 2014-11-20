root = exports ? this

class BalanceController
  constructor: () ->
    @loading = ko.observable false
    @savingPesee = ko.observable(false).syncWith "savingPesee"
    @poids = ko.observable()
    @ready = ko.pureComputed( =>
      return false if @poids() == undefined
      true
    ,@)
    @net = ko.pureComputed( =>
      return "" if @poids() == undefined
      @poids().netEnKilo()
    ,@)
    @brut = ko.pureComputed( =>
      return "" if @poids() == undefined
      @poids().netEnKilo()
    ,@)
    @tare = ko.pureComputed( =>
      return "" if @poids() == undefined
      @poids().tareEnKilo()
    ,@)
    ko.postbox.subscribe "tare", (data)=>
      @poids(undefined)
    return

  raz: =>
    @loading true
    $.get("/balance/cmd/z").then(@razOk).fail(@err)

  razOk: (data)=>
    @loading false
    toastr.success "Balance réinitialisée avec succès"
  err: (data)=>
    @loading false
    msg = "Une erreur est survenue, veuillez réessayer"
    if data.error().responseJSON.hasOwnProperty(['error'])
      msg = data.error().responseJSON.error
    toastr.error msg
    console.group "ERREUR"
    console.log data
    console.end
  pese: =>
    @loading true
    #@poids undefined
    $.get("/balance/pese").done(@peseOk).fail(@err)

  peseOk: (data)=>
    @loading false
    @poids(new Poids(data))
    @log()

  delTare: =>
    $.get("/balance/cmd/e").done(@delTareOk).fail(@err)
  delTareOk: ->
    toastr.success "Tare supprimée avec succès"

  doTare: =>
    $.get("/balance/cmd/t").done(@doTareOk).fail(@err)
  doTareOk: ->
    toastr.success "Balance tarée avec succès"

  log: =>
    console.log @poids()
    toastr.success "Poids net : #{@poids().netEnKilo()} <br/>
Poids brut : #{@poids().brutEnKilo()} <br/>"
#Poids tare : #{@poids().tareEnKilo()} <br/>"

  save: =>
    @loading true
    @poids undefined
    $.get("/balance/dsd").done(@saveOk).fail(@err)

  saveOk: (data)=>
    @poids new Poids(data)
    if @poids().net.val() <= 0 and @poids().brut.val() <= 0
      toastr.warning "Impossible d'enregistrer un poids inférieur ou égal à zéro"
      return
    ko.postbox.publish "newPoids", @poids()
    @log()

unless root.BalanceController
  root.BalanceController = BalanceController

