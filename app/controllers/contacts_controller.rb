class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  before_action :load_accounts, only: [:new, :edit, :create, :update]

  def index
    @contacts = Contact.includes(:account).order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
    @recent_donations = @contact.donations.order(donation_date: :desc).limit(5)
    @recurring_donations = @contact.recurring_donations.limit(5)
    @affiliations = @contact.affiliations.includes(:organization).limit(5)
  end

  def new
    @contact = Contact.new
  end

  def edit
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      redirect_to @contact, notice: 'Contact was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @contact.update(contact_params)
      redirect_to @contact, notice: 'Contact was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_url, notice: 'Contact was successfully deleted.'
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def load_accounts
    @accounts = Account.order(:name)
  end

  def contact_params
    params.require(:contact).permit(
      :first_name, :last_name, :salutation, :title, :department,
      :account_id, :primary_affiliation_id,
      :personal_email, :work_email, :alternate_email, :preferred_email,
      :home_phone, :mobile_phone, :work_phone, :other_phone, :preferred_phone,
      :mailing_street, :mailing_city, :mailing_state, :mailing_postal_code, :mailing_country,
      :birthdate, :lead_source, :description,
      :deceased, :do_not_contact, :do_not_call, :email_opt_out
    )
  end
end
