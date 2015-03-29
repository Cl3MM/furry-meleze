root = exports ? this

class PeseesController
  constructor: () ->
    @loading = ko.observable(false).syncWith "savingPesee"
    @ebsddId = $("#data").data('bid')
    @admin = $("#data").data('authorization')
    pesees = $("#data").data("pesees") ? []
    @pesees = ko.observableArray (new Pesee(p) for p in _.sortBy(pesees, (p)-> return p.dsd) )
    @tare = ko.observable().syncWith "tare"
    ko.postbox.subscribe "newPoids", @addPesee
    ko.postbox.subscribe "deletePesee", @delPesse
    ko.postbox.subscribe "adminDeletePesee", @adminDelPesse
    @onlyNew = ko.pureComputed( =>
      return _.compact @pesees.map (p)->
        return p if p.toAdd()
    ,@).extend rateLimit: 100

    @totalNet = ko.pureComputed( =>
      @pesees.reduce (n, p)->
        return n + p.poidsSansTare()
      , 0
    ,@)
    @totalTare = ko.pureComputed( =>
      @pesees.reduce (n, p)->
        return n + p.poids_tare()
      , 0
    ,@)
    @totalBrut = ko.pureComputed( =>
      @pesees.reduce (n, p)->
        return n + p.brut()
      , 0
    ,@)
  to_s: (data)->
    "#{data.toFixed(3)}".replace('.',',') + " kg"

  delPesse: (dsd)=>
    @pesees.remove (p)->
      if p.dsd() == dsd and p.added
        toastr.success "Pesée #{dsd} supprimée"
        return p
  adminDelPesse: (dsd)=>
    options =
      url: "/ebsdds/#{@ebsddId}/pesees/#{dsd}"
      type: "delete"
    $.ajax(options).done(@adminDelOk).fail(@adminDelErr)
  adminDelOk: (data)=>
    if data.deleted > 0
      toastr.success "Pesée ##{data.id} supprimée"
    else
      toastr.warning "Pesée ##{data.id} non supprimée"
    @pesees.remove (p)->
      return p.dsd() == data.id

  adminDelErr: (data)=>
    console.group "Erreur Suppresion Pesée Admin"
    console.log data
    console.end
    toastr.error "#{data.responseJSON.error}"
    @pesees.each (p)->
      p.loading(false) if p.dsd() == data.responseJSON.id
  addPesee: (data)=>
    pesee =
      brut: data.brut.val
      net: data.net.val
      tare: data.tare.val
      dsd: data.dsd.val
      date: data.date.val
      heure: data.heure.val
      added: true
      nom_tare: @tare().nom()
      poids_tare: @tare().poids()

    @pesees.push new Pesee(pesee)

  save: =>
    if @onlyNew().length is 0
      toastr.warning "Veuillez effectuer une pesée"
      return
    ko.postbox.publish "savingPesee", true
    data =
      pesees: ko.mapping.toJS @onlyNew()
    $.post("/balance/save/#{@ebsddId}", data).done(@saveOk).fail(@saveErr)

  saveOk: (data)=>
    ko.postbox.publish "savingPesee", false
    toastr.success "Pesée enregistrée avec succès"
    @pesees.each (p)->
      p.toAdd(false) if p.toAdd()
    @pesees.valueHasMutated()

  saveErr: (err)=>
    console.group "Erreur"
    console.log err
    console.groupEnd()

unless root.PeseesController
  root.PeseesController = PeseesController

