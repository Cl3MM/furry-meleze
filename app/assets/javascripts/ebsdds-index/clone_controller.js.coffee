root = exports ? this

class CloneController
  constructor: ->
    return unless $(".massclone").length > 0
    @produits  = $("#dechets").data 'dechets'
    @cloned = []
    @isShowing = false
    @selected = []
    @ebsdd = ko.observable()
    @loading = false
    console.group "Building Clone Controller"
    console.log @
    console.groupEnd()
    #ko.mapping.fromJS(data, {}, @)

    ko.track @, deep: true
    ko.getObservable(@, 'isShowing').subscribe (niou)=>
      console.log 'Modal visibility: ' + niou
      $("#cloneModal").modal(if niou then 'show' else 'hide')
      unless niou
        @selected.removeAll()
        @ebsdd = null

  toggle: (id)=>
    console.log id
    @ebsdd = id
    @isShowing = !@isShowing
    @selected.removeAll()

  massClone: =>
    console.log 'clicked !'
    return unless @ebsdd and @selected[0]
    @loading = true
    url = "/ebsdds/#{@ebsdd}/clone/en/masse"
    console.log "Posting to #{url}"
    data =
      ids: @selected.map (p)-> p.id
    $.post(url, data).done @updateUi
      .error @error
    return

  formatEbsddId: (id)->
    ar = "#{id}".split('')
    "#{ar.slice(0,4).join('')} #{ar.slice(4,6).join('')} #{ar.slice(6,8).join('')} #{ar.slice(8).join('')}"

  updateUi: (data)=>
    @isShowing = false
    @loading = false
    @cloned.push c for c in data
    console.log "Yeah!"
    console.log data
    console.log @
  error: (err)=>
    @loading = false
    console.error "Une erreur est survenue"
    console.error err
    toastr.error "Impossible de dupliquer l'ebsdds"

unless root.CloneController
  root.CloneController = CloneController

