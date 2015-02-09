#= require knockout
#= require knockout.mapping
#= require moment
#= require knockout-postbox.js
#= require lodash
#= require underscore-ko-1.6.0

root = exports ? this

class Header
  constructor: (data)->
    @title = ko.observable data.title
    @prop = ko.observable data?.prop
    @sort = ko.observable true
    @sortFn = data?.sort
    @descSort = (a,b)=>
      @_sort(a,b)
    @ascSort = (a,b)=>
      @_sort(b,a)

  _sort: (a,b)=>
    a = a[@prop()]
    b = b[@prop()]
    @sortFn(a,b)

  clicked: =>
    @sort !@sort()
    ko.postbox.publish 'header:click', @

  printMe: =>
    console.log "Print Me", @title()
class Ebsdd
  constructor: (data)->
    ko.mapping.fromJS(data, {}, @)
    @justif = ko.observable false
    #@justif.subscribe (niou)=>
      #ko.postbox.publish 'ebsdd:justif', @

class EbsddsVm
  constructor: ->
    @id = $('#model').data 'id'
    @data = ko.observableArray ( new Ebsdd(e) for e in $('#model').data 'ebsdds' )
    @headers = ko.observableArray [
      { title: 'Id', prop: 'id' }
      { title: 'Denomination', prop: 'nom' }
      { title: 'Poids', prop: 'poids_f' }
      { title: 'Producteur', prop: 'producteur' }
      { title: '#CAP', prop: 'cap' }
      { title: 'Date de Transport', prop: 'transport', sort: (a,b)->
        ma = moment(a, 'DD/MM/YYYY')
        mb = moment(b, 'DD/MM/YYYY')
        if ma.isBefore mb then -1 else if ma.isAfter mb then 1 else 0
      }
      { title: 'Justif' }
    ].map (h)-> new Header(h)
    @justifs = ko.observableArray []
    @justifs.subscribe (niou)->
      console.log niou

    @activeSort = @headers[0]
    #ko.postbox.subscribe 'ebsdd:justif', @checked

    @justifLnk = ko.computed =>
      ids = _.map @justifs(), (j)-> "ids[]=#{j.id()}"
      console.log ids
      url = "/bon_de_sorties/justif/#{@id}?#{ids.join('&')}"
      console.log url
      return url

    ko.postbox.subscribe 'header:click', @sort

  sort: (header)=>
    @activeSort = header
    if @activeSort.sortFn
      return @data.sort ( if @activeSort.sort() then @activeSort.ascSort else @activeSort.descSort )

    prop = @activeSort.prop()
    return unless prop

    ascSort = (a, b) ->
      if a[prop] < b[prop] then -1 else if a[prop] > b[prop] then 1 else if a[prop] == b[prop] then 0 else 0

    descSort = (a, b) ->
      if a[prop] > b[prop] then -1 else if a[prop] < b[prop] then 1 else if a[prop] == b[prop] then 0 else 0

    sortFunc = unless @activeSort.sort() then ascSort else descSort
    @data.sort sortFunc

unless root.EbsddsVm
  root.EbsddsVm = EbsddsVm

$ ->
  root.vm = new EbsddsVm()
  ko.applyBindings root.vm
