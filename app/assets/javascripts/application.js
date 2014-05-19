// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require jquery.ui.datepicker
//= require jquery.ui.datepicker-fr
//= require select2/select2
//= require select2/select2_locale_fr
//= require raphael
//= require morris
//= require jquery.tablesorter.min
//= require jquery.tablesorter.widgets.min
//= require jquery.tablesorter.widgets-filter-formatter-select2
//= require jquery.metadata
//= require_self
$(function() {
  $('.dropdown-toggle').dropdown();
  //$('.collapse').collapse();
  if( $("a.touletip").length )
    $("a.touletip").tooltip();
  $('.dropdown-toggle').dropdown();
});
