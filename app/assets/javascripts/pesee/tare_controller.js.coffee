root = exports ? this

class TareController
  constructor: (data = []) ->
    tares = (new Tare(t) for t in _.sortBy( data, (t) -> return t.nom()) )
    @tares = ko.observableArray( tares )
    @tare = ko.observableArray tares
    @tareSelection = ko.observable()
    @tareSelection.subscribe (niou)=>
      if niou == undefined
        ko.postbox.publish "tareReady", false
        return
      ko.postbox.publish "tareReady", true
      @tare(niou)
      ko.postbox.publish "tare", niou

unless root.TareController
  root.TareController = TareController

