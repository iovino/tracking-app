class SitesController < ApplicationController
  before_action :set_site, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /sites
  # GET /sites.json
  def index
    @sites_without_tracking = Site.where(:active => true, :status => 0)
    @sites_with_tracking    = Site.where(:active => true, :status => 1)
    @sites_pending_scan     = Site.where(:active => true, :status => 2)
    @sites_not_active       = Site.where(:active => false)
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
  end

  # GET /sites/new
  def new
    @site = Site.new
  end

  # GET /sites/1/edit
  def edit
    @errors = SiteError.where(:site_id => params[:id]).order(created_at: :desc)
  end

  # POST /sites
  # POST /sites.json
  def create
    @site = Site.new(site_params)

    if params[:prioritize_urls]
      params[:prioritize_urls].each do |site_url|
        if site_url.empty? == false
          @site.site_urls.build(:url => site_url)
        end
      end
    end

    respond_to do |format|
      if @site.save
        format.html { redirect_to sites_path, notice: 'Site was successfully created.' }
        format.json { render :show, status: :created, location: @site }
      else
        format.html { render :new }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sites/1
  # PATCH/PUT /sites/1.json
  def update

    @site.site_urls.destroy_all

    if params[:prioritize_urls]
      params[:prioritize_urls].each do |site_url|
        if site_url.empty? == false
          @site.site_urls.build(:url => site_url)
        end
      end
    end


    respond_to do |format|
      if @site.update(site_params)
        format.html { redirect_to sites_path, notice: 'Site was successfully updated.' }
        format.json { render :show, status: :ok, location: @site }
      else
        format.html { render :edit }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    @site.destroy
    respond_to do |format|
      format.html { redirect_to sites_url, notice: 'Site was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site
      @site = Site.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_params
      params.require(:site).permit(:name, :homepage, :active, :ua_codes, :user_id)
    end
end
