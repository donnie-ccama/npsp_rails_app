class RecurringDonationsController < ApplicationController
  def index
    @recurring_donations = RecurringDonation.includes(:contact, :campaign).order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
    @recurring_donation = RecurringDonation.find(params[:id])
  end

  def new
    @recurring_donation = RecurringDonation.new
  end

  def edit
    @recurring_donation = RecurringDonation.find(params[:id])
  end

  def create
    @recurring_donation = RecurringDonation.new(recurring_donation_params)
    if @recurring_donation.save
      redirect_to @recurring_donation, notice: 'Recurring donation was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @recurring_donation = RecurringDonation.find(params[:id])
    if @recurring_donation.update(recurring_donation_params)
      redirect_to @recurring_donation, notice: 'Recurring donation was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recurring_donation = RecurringDonation.find(params[:id])
    @recurring_donation.destroy
    redirect_to recurring_donations_url, notice: 'Recurring donation was successfully deleted.'
  end

  private

  def recurring_donation_params
    params.require(:recurring_donation).permit(:contact_id, :campaign_id, :amount, :frequency, :start_date, :end_date, :status, :payment_method)
  end
end
