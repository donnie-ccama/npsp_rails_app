class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]
  before_action :load_parent_accounts, only: [:new, :edit, :create, :update]

  def index
    @accounts = Account.order(created_at: :desc)
    
    # Apply filters
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @accounts = @accounts.where("name ILIKE ?", search_term)
    end
    
    if params[:account_type].present?
      @accounts = @accounts.where(account_type: params[:account_type])
    end
    
    @accounts = @accounts.page(params[:page]).per(25)
  end

  def show
    @contacts = @account.contacts.limit(10)
    @recent_donations = @account.donations.order(donation_date: :desc).limit(5)
    @recurring_donations = @account.recurring_donations.limit(5)
  end

  def new
    @account = Account.new
  end

  def edit
  end

  def create
    @account = Account.new(account_params)
    if @account.save
      redirect_to @account, notice: 'Account was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @account.update(account_params)
      redirect_to @account, notice: 'Account was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @account.destroy
    redirect_to accounts_url, notice: 'Account was successfully deleted.'
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def load_parent_accounts
    @parent_accounts = Account.where(account_type: 'organization').where.not(id: @account&.id).order(:name)
  end

  def account_params
    params.require(:account).permit(
      :name, :account_type, :record_type,
      :phone, :fax, :website,
      :billing_street, :billing_city, :billing_state, :billing_postal_code, :billing_country,
      :shipping_street, :shipping_city, :shipping_state, :shipping_postal_code, :shipping_country,
      :industry, :annual_revenue, :number_of_employees,
      :formal_greeting, :informal_greeting,
      :parent_account_id, :description
    )
  end
end
