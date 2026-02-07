class CampaignsController < ApplicationController
  def index
    @campaigns = Campaign.order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
    @campaign = Campaign.find(params[:id])
  end

  def new
    @campaign = Campaign.new
  end

  def edit
    @campaign = Campaign.find(params[:id])
  end

  def create
    @campaign = Campaign.new(campaign_params)
    if @campaign.save
      redirect_to @campaign, notice: 'Campaign was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @campaign = Campaign.find(params[:id])
    if @campaign.update(campaign_params)
      redirect_to @campaign, notice: 'Campaign was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @campaign = Campaign.find(params[:id])
    @campaign.destroy
    redirect_to campaigns_url, notice: 'Campaign was successfully deleted.'
  end

  private

  def campaign_params
    params.require(:campaign).permit(:name, :description, :start_date, :end_date, :goal_amount, :status, :campaign_type)
  end
end
