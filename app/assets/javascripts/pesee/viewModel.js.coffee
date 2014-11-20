root = exports ? this

# ViewModel class
class ViewModel
  constructor: (data = []) ->
    tares = (new Tare(t) for t in data)
    @tareCtrl = new TareController( tares )
    @tareReady = ko.observable(false).syncWith("tareReady")
    @balanceCtrl = new BalanceController()
    @peseesCtrl = new PeseesController()

unless root.ViewModel
  root.ViewModel = ViewModel

$ ->
  root.vm = new ViewModel( $("#data").data('tares') )
  ko.applyBindings vm
