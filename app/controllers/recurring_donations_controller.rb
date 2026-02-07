class RecurringDonationsController < ApplicationController
  before_action :set_recurring_donation, only: [:show, :edit, :update, :destroy]
  before_action :load_associations, only: [:new, :edit, :create, :update]

  def index
    @recurring_donations = RecurringDonation.includes(:contact, :campaign).order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
    @donations = @recurring_donation.donations.order(close_date: :desc).limit(10)
  end

  def new
    @recurring_donation = RecurringDonation.new(start_date: Date.current)
  end

  def edit
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
    if @recurring_donation.update(recurring_donation_params)
      redirect_to @recurring_donation, notice: 'Recurring donation was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recurring_donation.destroy
    redirect_to recurring_donations_url, notice: 'Recurring donation was successfully deleted.'
  end

  private

  def set_recurring_donation
    @recurring_donation = RecurringDonation.find(params[:id])
  end

  def load_associations
    @contacts = Contact.order(:last_name, :first_name)
    @accounts = Account.order(:name)
    @campaigns = Campaign.order(:name)
  end

  def recurring_donation_params
    params.require(:recurring_donation).permit(
      :name, :contact_id, :account_id, :amount, :recurring_type, :installment_period,
      :day_of_month, :start_date, :effective_date, :date_established, :planned_installments,
      :status, :status_reason, :payment_method, :campaign_id
    )
  end
end
