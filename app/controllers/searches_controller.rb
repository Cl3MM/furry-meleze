class SearchesController < ApplicationController
  #layout false
  # GET /searches
  # GET /searches.json
  def index
    @searches = Search.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @searches }
    end
  end

  # GET /searches/1
  # GET /searches/1.json
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

    respond_to do |format|
      format.html # new.html.erb
      format.js # new.html.erb
      format.json { render json: @search }
    end
  end

  # GET /searches/1/edit
  def edit
    @search = Search.find(params[:id])
  end

  # POST /searches
  # POST /searches.json
  def create
    @search = Search.new(params[:search])

    @ebsdds = Ebsdd.between(bordereau_date_creation: @search.date_min..@search.date_max).paginate(page: params[:page], per_page: 15)
    @status = (params.has_key?(:status) ? params[:status].to_sym : :empty)
    respond_to do |format|
      format.html { render template: "ebsdds/index" }
      format.json { render json: @search.errors, status: :unprocessable_entity }
    end
    #respond_to do |format|
      #if @search.save
        #format.html { redirect_to @search, notice: 'Search was successfully created.' }
        #format.json { render json: @search, status: :created, location: @search }
      #else
        #format.html { render action: "new" }
        #format.json { render json: @search.errors, status: :unprocessable_entity }
      #end
    #end
  end

  # PUT /searches/1
  # PUT /searches/1.json
  def update
    @search = Search.find(params[:id])

    respond_to do |format|
      if @search.update_attributes(params[:search])
        format.html { redirect_to @search, notice: 'Search was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /searches/1
  # DELETE /searches/1.json
  def destroy
    @search = Search.find(params[:id])
    @search.destroy

    respond_to do |format|
      format.html { redirect_to searches_url }
      format.json { head :no_content }
    end
  end
end
