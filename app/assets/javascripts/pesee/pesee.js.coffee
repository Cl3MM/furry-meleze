root = exports ? this

class Pesee
  constructor: (data = []) ->
    ko.mapping.fromJS(data, {}, @)
    @loading = ko.observable(false)
    @jourJ = ko.pureComputed( =>
      moment(@date(), 'DDMMYY').format('DD-MM-YYYY')
    ,@)
    @heureH = ko.pureComputed( =>
      moment(@heure(), 'HHmmss').format('HH:mm:ss')
    ,@)
    @poidsSansTare = ko.pureComputed( =>
      @net() - @poids_tare()
    ,@)
    @poidsSansTareEnKilo = ko.pureComputed( =>
      "#{@poidsSansTare().toFixed(3)}".replace('.',',') + " kg"
    ,@)
    @toAdd = ko.observable( @.hasOwnProperty ['added'] )

  hasBeenAdded: =>
    delete @['added'] if @toAdd()
    #@toAdd.valueHasMutated()

  tareKg: =>
    net = "#{@poids_tare().toFixed(3)}".replace('.',',')
    "#{net} kg"
  netKg: =>
    net = "#{@net().toFixed(3)}".replace('.',',')
    "#{net} kg"
  brutKg: =>
    brut = "#{@brut().toFixed(3)}".replace('.',',')
    "#{brut} kg"
  forceDeleteMe: =>
    #return unless $("#data").data("authorization")
    @loading(true)
    ko.postbox.publish "adminDeletePesee", @dsd()
  deleteMe: =>
    return unless @toAdd()
    ko.postbox.publish "deletePesee", @dsd()
unless root.Pesee
  root.Pesee = Pesee
