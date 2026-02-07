class DonationsController < ApplicationController
  def index
    @donations = Donation.includes(:contact, :account, :campaign).order(donation_date: :desc).page(params[:page]).per(25)
  end

  def show
    @donation = Donation.find(params[:id])
  end

  def new
    @donation = Donation.new
  end

  def edit
    @donation = Donation.find(params[:id])
  end

  def create
    @donation = Donation.new(donation_params)
    if @donation.save
      redirect_to @donation, notice: 'Donation was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @donation = Donation.find(params[:id])
    if @donation.update(donation_params)
      redirect_to @donation, notice: 'Donation was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @donation = Donation.find(params[:id])
    @donation.destroy
    redirect_to donations_url, notice: 'Donation was successfully deleted.'
  end

  private

  def donation_params
    params.require(:donation).permit(:contact_id, :account_id, :campaign_id, :amount, :donation_date, :donation_type, :status, :payment_method)
  end
end
