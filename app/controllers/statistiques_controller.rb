class StatistiquesController < ApplicationController
  before_filter :authenticate_utilisateur!

  def index
    @alertes     = Ebsdd.seuils
    @camions     = Ebsdd.camions
    @dest        = Destination.to_select
  end
  def camions
    format_str = "%d-%m-%Y"
    date_min = Date.strptime(params[:date_min], format_str) rescue Date.today.beginning_of_month
    date_max = Date.strptime(params[:date_max], format_str) rescue Date.today.end_of_month
    data = Ebsdd.camions(date_min, date_max)
    render json: data
  end
  def destinations
    format_str = "%d-%m-%Y"
    date_min = Date.strptime(params[:date_min], format_str) rescue Date.today.beginning_of_month
    date_max = Date.strptime(params[:date_max], format_str) rescue Date.today.end_of_month
    dest_id = params[:dest_id]
    data = BonDeSortie.destinations(dest_id, date_min, date_max)
    render json: data
  end
end

