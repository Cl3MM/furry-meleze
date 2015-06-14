root = exports ? this

class ViewModel
  constructor: ->
    @sortiesCtrl = new SortiesController()
    ko.track @, deep: true

unless root.ViewModel
  root.ViewModel = ViewModel

$ ->
  root.vm = new ViewModel()
  ko.applyBindings vm

