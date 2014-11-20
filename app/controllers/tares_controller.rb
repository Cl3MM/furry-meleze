class TaresController < ApplicationController
  # GET /tares
  # GET /tares.json
  def index
    @tares = Tare.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tares }
    end
  end

  # GET /tares/1
  # GET /tares/1.json
  def show
    @tare = Tare.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tare }
    end
  end

  # GET /tares/new
  # GET /tares/new.json
  def new
    @tare = Tare.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tare }
    end
  end

  # GET /tares/1/edit
  def edit
    @tare = Tare.find(params[:id])
  end

  # POST /tares
  # POST /tares.json
  def create
    @tare = Tare.new(params[:tare])

    respond_to do |format|
      if @tare.save
        format.html { redirect_to @tare, notice: 'Tare créée avec succès.' }
        format.json { render json: @tare, status: :created, location: @tare }
      else
        format.html { render action: "new" }
        format.json { render json: @tare.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tares/1
  # PUT /tares/1.json
  def update
    @tare = Tare.find(params[:id])

    respond_to do |format|
      if @tare.update_attributes(params[:tare])
        format.html { redirect_to @tare, notice: 'Tare modifiée avec succès.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tare.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tares/1
  # DELETE /tares/1.json
  def destroy
    @tare = Tare.find(params[:id])
    @tare.destroy

    respond_to do |format|
      format.html { redirect_to tares_url }
      format.json { head :no_content }
    end
  end
end
