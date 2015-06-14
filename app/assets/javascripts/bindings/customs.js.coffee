ko.bindingHandlers.pikaday =
  init: (element, valueAccessor, allBindings) ->
    observable = valueAccessor()
    model      = if 'pikModel' of allBindings() then allBindings().pikModel else null
    property   = if 'pikProp' of allBindings() then allBindings().pikProp else null
    val        = if ko.isObservable observable then observable() else observable
    $(element).val val.format "DD-MM-YYYY"
    options =
      field: $(element)[0]
      format: "DD-MM-YYYY"
      i18n:
        defaultDate : val
        setDefaultDate : true
        showWeekNumber: true
        previousMonth : 'Mois Suivant'
        nextMonth     : 'Mois Précédent'
        months        : ( i for i in moment.months() )
        weekdays      : ( i for i in moment.weekdays() )
        weekdaysShort : ( i for i in moment.weekdaysShort() )
      onSelect: ->
        if ko.isObservable val
          val this.getMoment()
        else
          obs = ko.getObservable(model, property)
          obs this.getMoment()

    picker = new Pikaday(options)
    $(element).data('pika', picker)
    $(element).addClass 'pikachu'
    ko.utils.domNodeDisposal.addDisposeCallback element, ->
      picker.destroy()
