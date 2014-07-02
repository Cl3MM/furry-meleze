# encoding : utf-8

class SearchesController < ApplicationController
  before_filter :authenticate_utilisateur!

  def show
    @search = Search.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @search }
    end
  end

  # GET /searches/new
  # GET /searches/new.json
  def new
    @search = Search.new
  end

  def create
    format_str = "%d-%m-%Y"
    if params[:search].values.map{ |i| i.blank? ? nil : i}.compact.any?
      if params[:search][:date_max].present?
        params[:search][:date_max] = Date.strptime(params[:search][:date_max], format_str) rescue Date.today.end_of_day
      end
      if params[:search][:date_min].present?
        params[:search][:date_min] = Date.strptime(params[:search][:date_min], format_str) rescue Date.today.beginning_of_day
      end
      min = params[:search][:poids_min]
      max = params[:search][:poids_max]

      params[:search][:poids_min], params[:search][:poids_max] = max, min if !max.blank? && min.to_f > max.to_f
      params[:search].delete(:poids_max) if params[:search][:poids_max].to_f == 0.0

      @search = Search.create!(params[:search])

      #@ebsdds = Ebsdd.between(bordereau_date_creation: @search.date_min..@search.date_max).paginate(page: params[:page], per_page: 15)
      #@ebsdds = Ebsdd.where(bid: /#{@search.bordereau_id}/).paginate(page: params[:page], per_page: 15)
      #@status = (params.has_key?(:status) ? params[:status].to_sym : :empty)
      redirect_to @search
    else
      redirect_to new_search_path, alert: "Veuillez sélectionner au moins un critère"
    end
  end
  def gestion_matiere
    @search = Search.find(params[:id])
    respond_to do |format|
      format.html
      format.csv { send_data @search.export_gestion_matiere.encode("iso-8859-1"), filename: "Export_gestion_matiere_DD_#{Date.today.strftime("%d-%m-%Y")}.csv", type: 'text/csv; charset=iso-8859-1;' }
    end
  end

end
