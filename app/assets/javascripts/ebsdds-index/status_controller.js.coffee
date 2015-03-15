root = exports ? this

class StatusController
  constructor:  ->
    @status = ko.observable $("#model").data('status')
    @ebsdedes = ko.observableArray([]) # $("#model").data('bids')
    data = $("#model").data('bids')
    @bids = data
    @check = ko.observable(false)
    @check.subscribe(@checkAll)
    return

  pretty_status: =>
    switch @status
      when "en_attente"
        return "En Attente Réception"
      when "Nouveau"
        return "Nouveau"
  selectForDeleteAll: =>
    $('.deleteme').each ->
      $(this).toggleClass('hidden')
  deleteAll: =>
    if @ebsdedes().length == 0
      alert("Veuillez sélectionner les eBsdds à supprimer")
      return
    ok = confirm "Etes vous sur de vouloir supprimer ces eBsdds ?"
    if ok
      data =
        bids: @ebsdedes()
      options =
        url: '/ebsdds/mark_as_deleted'
        type: 'delete'
        data: data
      $.ajax(options).then(@deleteOk).fail(@deleteErr)
    else
      console.log "user canceled..."

  deleteErr: (data)=>
    toastr.error 'Impossible de supprimer la sélection...'
    console.log data

  deleteOk: (data)=>
    toastr.success 'Suppression effectuée avec succès'
    @selectForDeleteAll()
    @fadeDeleted(data)

  fadeDeleted: (data)=>
    _.each data, (d)->
      console.log "Fading out #{d}..."
      $("##{d}").fadeOut()
    setTimeout ( ()->
      location.reload() if $("#ebsdds tbody tr:visible").length == 0
    ), 800

  checkAll: (data)=>
    if data
      @ebsdedes([])
      @ebsdedes(@bids)
    else
      @ebsdedes([])
unless root.StatusController
  root.StatusController = StatusController
