class PlotsController < ApplicationController

  before_action :set_plot, only: [:show, :edit, :update, :destroy]
  before_action :login_required, except: [:index, :show]
  before_action :admin_required, except: [:index, :show]

  def index
    @plots = Plot.all.order(:plot_id)
  end

  def show
  end

  def download_qr
    @qr = RQRCode::QRCode.new(url_for(action: 'show', only_path: false), :size => 5, :level => :h )
    png = @qr.as_png(
          resize_gte_to: false,
          resize_exactly_to: false,
          fill: 'white',
          color: 'black',
          size: 360,
          border_modules: 4,
          module_px_size: 6,
          file: nil # path to write
          )
    send_data( png, :filename => "plot-#{Plot.find(params[:id]).id}-qr-code.png" )
  end

  def new
    @plot = Plot.new
    @plants = Plant.all
  end

  def edit
    @plants = Plant.all
  end

  def create
    @plot = Plot.new(plot_params)
    if @plot.save
      redirect_to plots_path
      flash[:success] = 'Plot was successfully created.'
    else
      @plants = Plant.all
      render 'new'
    end
  end

  def update
    if @plot.update(plot_params)
      redirect_to @plot
      flash[:success] = 'Plot was successfully updated.'
    else
      @plants = Plant.all
      render 'edit'
    end
  end

  def destroy
    @plot.destroy
    redirect_to plots_path
    flash[:success] = 'Plot was successfully destroyed.'
  end

  private

    def set_plot
      @plot = Plot.find(params[:id])
    end

    def plot_params
      params.require(:plot).permit(:plot_id, :featured_plant_id, :latitude, :longitude, :elevation, :area, :location_description, :aspect, :origin, :inoculated, :initial_planting_date, :initial_succession, :photo)
    end
end
