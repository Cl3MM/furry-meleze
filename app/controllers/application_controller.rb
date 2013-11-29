class ApplicationController < ActionController::Base
  protect_from_forgery

  def fa_link_to path, text, icon, options = {}
    view_context.link_to(path, options) do
      icon += " margin-right-4" if icon =~ /lg|\dx/
      view_context.fa_icon icon, text: text
    end
  end
  helper_method :fa_link_to
end
