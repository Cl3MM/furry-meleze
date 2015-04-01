root = exports ? this

class BalanceController
  constructor: () ->
    @loading = ko.observable false
    @showManual = ko.observable false
    @fakePoids = ko.observable()
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
    @manualTare = ko.observable 0
    ko.postbox.subscribe "tare", (data)=>
      @manualTare data
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
    console.groupEnd()

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

  toggleManual: =>
    @showManual !@showManual()

  save: =>
    @loading true
    @poids undefined
    if @fakePoids()?
      poids =
        net:
          val: parseFloat(@fakePoids()) #- @manualTare().poids()
        brut:
          val : parseFloat(@fakePoids()) #+ @manualTare().poids()
        tare:
          val : @manualTare().poids()
        dsd:
          val: 1 + moment().format("0MMDDHHmm")
        date:
          val: moment().format("DDMMYY")
        heure:
          val: moment().format("HHmmss")
      @fakePoids null
      @saveOk poids
      return
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

