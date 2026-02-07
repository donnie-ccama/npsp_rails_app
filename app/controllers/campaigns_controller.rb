class CampaignsController < ApplicationController
  before_action :set_campaign, only: [:show, :edit, :update, :destroy]

  def index
    @campaigns = Campaign.order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
    @donations = @campaign.donations.order(close_date: :desc).limit(10)
    @recurring_donations = @campaign.recurring_donations.limit(5)
  end

  def new
    @campaign = Campaign.new
  end

  def edit
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
    if @campaign.update(campaign_params)
      redirect_to @campaign, notice: 'Campaign was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @campaign.destroy
    redirect_to campaigns_url, notice: 'Campaign was successfully deleted.'
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(
      :name, :campaign_type, :status, :start_date, :end_date,
      :expected_revenue, :budgeted_cost, :actual_cost,
      :expected_response, :number_sent, :active, :description, :parent_campaign_id
    )
  end
end
