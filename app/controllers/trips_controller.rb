class TripsController < ApplicationController
  before_action :http_basic_auth, only: :oj
  before_action :set_trip, only: [:show, :edit, :destroy]
  after_action :remove_old_trips, only: :refresh
  after_action :update_temperatures, only: :refresh

  def oj
    load_trips

    respond_to do |format|
      format.html { render :oj }
    end
  end

  def select
    prev_trip = Trip.find_by_featured(true)
    @trip = Trip.find(params[:trip_id])
    @trip.featured = true

    if @trip.save
      prev_trip.update_column(:featured, false)
    end

    redirect_to show_path(@trip.id)
  end

  def refresh
    Trip.generate_flights

    redirect_to oj_path(refresh: true)
  end

  def about

    respond_to do |format|
      format.html { render :about }
    end
  end

  def contact

    respond_to do |format|
      format.html { render :contact }
    end
  end

  # GET /trips
  # GET /trips.json
  def index
    # redirect /oj to here
    load_trips

    respond_to do |format|
      format.html { render :index }
    end
  end

  # GET /trips/1
  # GET /trips/1.json
  def show

    respond_to do |format|
      format.html { render :show }
    end
  end

  # GET /trips/new
  def new
    @trip = Trip.new
  end

  # GET /trips/1/edit
  def edit
  end

  # POST /trips
  # POST /trips.json
  def create
    prev_trip = Trip.where(featured: true)
    @trip = Trip.find(params[:trip_id])
    @trip.featured = true

    if @trip.save
      prev_trip.update_column(:featured, false)
    end

    respond_to do |format|
      if @trip.save
        format.html { redirect_to @trip, notice: 'Trip was successfully created.' }
        format.json { render :show, status: :created, location: @trip }
      else
        format.html { render :new }
        format.json { render json: @trip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trips/1
  # PATCH/PUT /trips/1.json
  def update
    @trip = Trip.find(params[:id])
    respond_to do |format|
      if @trip.update(trip_params)
        format.html { redirect_to oj_path, notice: 'Trip was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /trips/1
  # DELETE /trips/1.json
  def destroy
    @trip.destroy
    respond_to do |format|
      format.html { redirect_to trips_url, notice: 'Trip was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trip
      @trip = params[:id].present? ? Trip.find(params[:id]) : Trip.where(featured: true).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trip_params
      params.require(:trip).permit(:code, :name, :price, :temperature, :depart_at, :return_at, :url)
    end

    def load_trips
      if Trip.where(featured: true).blank?
        Trip.last.update_column(:featured, true)
      end
      @trips = Trip.admin_trips_display!
    end

    def remove_old_trips
      Trip.remove_old_trips
    end

    def update_temperatures
      Trip.update_temperatures
    end
end
