class DonationsController < ApplicationController
  before_action :set_donation, only: [:show, :edit, :update, :destroy]
  before_action :load_associations, only: [:new, :edit, :create, :update]

  def index
    @donations = Donation.includes(:contact, :account, :campaign).order(close_date: :desc)
    
    # Apply filters
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @donations = @donations.joins("LEFT JOIN contacts ON donations.contact_id = contacts.id").joins("LEFT JOIN accounts ON donations.account_id = accounts.id").where(
        "contacts.first_name ILIKE ? OR contacts.last_name ILIKE ? OR accounts.name ILIKE ?",
        search_term, search_term, search_term
      )
    end
    
    if params[:stage].present?
      @donations = @donations.where(stage: params[:stage])
    end
    
    if params[:start_date].present?
      @donations = @donations.where("close_date >= ?", params[:start_date])
    end
    
    if params[:end_date].present?
      @donations = @donations.where("close_date <= ?", params[:end_date])
    end
    
    if params[:min_amount].present?
      @donations = @donations.where("amount >= ?", params[:min_amount])
    end
    
    if params[:max_amount].present?
      @donations = @donations.where("amount <= ?", params[:max_amount])
    end
    
    @donations = @donations.page(params[:page]).per(25)
  end

  def show
    @payments = @donation.payments.order(payment_date: :desc)
  end

  def new
    @donation = Donation.new(close_date: Date.current, stage: :pledged)
  end

  def edit
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
    if @donation.update(donation_params)
      redirect_to @donation, notice: 'Donation was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @donation.destroy
    redirect_to donations_url, notice: 'Donation was successfully deleted.'
  end

  private

  def set_donation
    @donation = Donation.find(params[:id])
  end

  def load_associations
    @contacts = Contact.order(:last_name, :first_name)
    @accounts = Account.order(:name)
    @campaigns = Campaign.order(:name)
  end

  def donation_params
    params.require(:donation).permit(
      :name, :contact_id, :account_id, :campaign_id, :recurring_donation_id,
      :amount, :close_date, :stage, :probability, :record_type, :donation_type,
      :lead_source, :next_step, :description,
      :gift_type, :acknowledgment_status, :acknowledgment_date,
      :tribute_type, :honoree_name, :honoree_contact_id, :notification_recipient_id,
      :matching_gift_status, :matching_gift_account_id, :matching_gift_donation_id
    )
  end
end
