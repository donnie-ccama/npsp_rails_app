class AccountsController < ApplicationController
  def index
    @accounts = Account.order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
    @account = Account.find(params[:id])
  end

  def new
    @account = Account.new
  end

  def edit
    @account = Account.find(params[:id])
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
    @account = Account.find(params[:id])
    if @account.update(account_params)
      redirect_to @account, notice: 'Account was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @account = Account.find(params[:id])
    @account.destroy
    redirect_to accounts_url, notice: 'Account was successfully deleted.'
  end

  private

  def account_params
    params.require(:account).permit(:name, :account_type, :phone, :website, :description)
  end
end
