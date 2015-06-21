//= require knockout
//= require knockout.mapping
//= require knockout-postbox.min.js
//= require knockout-es5.min.js
//= require toastr
//= require moment
//= require moment/fr.js
//= require lodash
//= require underscore-ko-1.6.0
//= require_tree ./ebsdds-index
//
toastr.options = {
  "closeButton": true,
  "debug": false,
  "progressBar": true,
  "positionClass": "toast-bottom-right",
  "onclick": null,
  "showDuration": "300",
  "hideDuration": "1000",
  "timeOut": "2000",
  "extendedTimeOut": "1000",
  "showEasing": "swing",
  "hideEasing": "linear",
  "showMethod": "fadeIn",
  "hideMethod": "fadeOut"
}
$().ready(function() {
  window.vm = {
    statusCtrl: new StatusController(),
    fCtrl: new FiltresController(),
    cloneCtrl: new CloneController()
  };
  ko.applyBindings(window.vm);

  $("#per_page").change(function(e) {
    var url = window.location.search,
        pp  = 'par_page='+this.value
    if(!url) {
       url = '?' + pp
    } else {
        if(~url.indexOf("par_page") ) {
           url = url.replace(/par_page=\d+/, pp)
        } else {
            url = url + '&' + pp
        }
    }
    window.location=url;
  });
})
