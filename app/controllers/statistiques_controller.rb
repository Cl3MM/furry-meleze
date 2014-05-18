class StatistiquesController < ApplicationController
  before_filter :authenticate_utilisateur!

  def index
    @alertes     = Ebsdd.seuils
    @camions     = Ebsdd.camions
    @dest        = Destination.to_select
    @quantites   = Ebsdd.quantites
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
  def quantites
    format_str = "%d-%m-%Y"
    date_min = Date.strptime(params[:date_min], format_str) rescue Date.today.beginning_of_month
    date_max = Date.strptime(params[:date_max], format_str) rescue Date.today.end_of_month
    data = Ebsdd.quantites(date_min, date_max)
    render json: data
  end
  def quantites_to_csv
    format_str = "%d-%m-%Y"
    date_min = Date.strptime(params[:date_min], format_str) rescue Date.today.beginning_of_month
    date_max = Date.strptime(params[:date_max], format_str) rescue Date.today.end_of_month
    params[:format] = "csv"
    formats = [:csv]
    respond_to do |format|
      format.html
      format.csv { send_data Ebsdd.quantites_to_csv(date_min, date_max),
                   filename: "Quantites_de_dechets_presente_du_#{date_min.strftime("%d-%m-%y")}au#{date_max.strftime("%d-%m-%y")}.csv",
                   disposition: "attachment"
                 }
      #format.xls # { send_data @products.to_csv(col_sep: "\t") }
    end
  end
end

