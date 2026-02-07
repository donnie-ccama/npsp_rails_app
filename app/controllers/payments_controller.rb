class PaymentsController < ApplicationController
  before_action :set_payment, only: [:show, :edit, :update, :destroy]
  before_action :load_donations, only: [:new, :edit, :create, :update]

  def index
    @payments = Payment.includes(:donation).order(payment_date: :desc).page(params[:page]).per(25)
  end

  def show
  end

  def new
    @payment = Payment.new(payment_date: Date.current)
  end

  def edit
  end

  def create
    @payment = Payment.new(payment_params)
    if @payment.save
      redirect_to @payment, notice: 'Payment was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @payment.update(payment_params)
      redirect_to @payment, notice: 'Payment was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @payment.destroy
    redirect_to payments_url, notice: 'Payment was successfully deleted.'
  end

  private

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def load_donations
    @donations = Donation.order(close_date: :desc)
  end

  def payment_params
    params.require(:payment).permit(
      :donation_id, :amount, :payment_date, :scheduled_date,
      :paid, :payment_method, :check_reference_number, :written_off
    )
  end
end
