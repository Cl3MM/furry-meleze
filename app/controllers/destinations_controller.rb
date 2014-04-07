class DestinationsController < ApplicationController
  # GET /destinations
  # GET /destinations.json
  def index
    @destinations = Destination.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @destinations }
    end
  end

  # GET /destinations/1
  # GET /destinations/1.json
  def show
    @destination = Destination.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @destination }
    end
  end

  def find_by_nomenclature
    if params[:nomenclature].present?
      @destination = Destination.find_by(nomenclatures: params[:nomenclature])

      respond_to do |format|
        format.js
      end if @destination
    else
      respond_to do |format|
        format.js {render json: {} }
      end
    end
  end
  # GET /destinations/new
  # GET /destinations/new.json
  def new
    @destination = Destination.new
    @destination.nomenclatures = []

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @destination }
    end
  end

  # GET /destinations/1/edit
  def edit
    @destination = Destination.find(params[:id])
  end

  # POST /destinations
  # POST /destinations.json
  def create
    params[:destination][:nomenclatures] = params[:destination][:nomenclatures].split(",") if params[:destination][:nomenclatures].present? && params[:destination][:nomenclatures] =~ /,/
    @destination = Destination.new(params[:destination])

    respond_to do |format|
      if @destination.save
        format.html { redirect_to @destination, notice: 'Destination was successfully created.' }
        format.json { render json: @destination, status: :created, location: @destination }
      else
        format.html { render action: "new" }
        format.json { render json: @destination.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /destinations/1
  # PUT /destinations/1.json
  def update
    @destination = Destination.find(params[:id])
    params[:destination][:nomenclatures] = params[:destination][:nomenclatures].split(",") if params.has_key?(:destination) && params[:destination].has_key?(:nomenclatures)

    respond_to do |format|
      if @destination.update_attributes(params[:destination])
        format.html { redirect_to @destination, notice: 'Destination was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @destination.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /destinations/1
  # DELETE /destinations/1.json
  def destroy
    @destination = Destination.find(params[:id])
    @destination.destroy

    respond_to do |format|
      format.html { redirect_to destinations_url }
      format.json { head :no_content }
    end
  end
end
