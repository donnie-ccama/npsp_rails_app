class AddressesController < ApplicationController
  before_action :set_account
  before_action :set_address, only: [:edit, :update, :destroy]

  def new
    @address = @account.addresses.build
  end

  def create
    @address = @account.addresses.build(address_params)
    if @address.save
      redirect_to account_path(@account), notice: 'Address was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to account_path(@account), notice: 'Address was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to account_path(@account), notice: 'Address was successfully deleted.'
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_address
    @address = @account.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(
      :street, :city, :state, :postal_code, :country,
      :address_type, :default_address, :verified,
      :seasonal_start_month, :seasonal_start_day,
      :seasonal_end_month, :seasonal_end_day
    )
  end
end
