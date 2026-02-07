class PaymentsController < ApplicationController
  def index
    @payments = Payment.includes(:donation).order(payment_date: :desc).page(params[:page]).per(25)
  end

  def show
    @payment = Payment.find(params[:id])
  end

  def new
    @payment = Payment.new
  end

  def edit
    @payment = Payment.find(params[:id])
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
    @payment = Payment.find(params[:id])
    if @payment.update(payment_params)
      redirect_to @payment, notice: 'Payment was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy
    redirect_to payments_url, notice: 'Payment was successfully deleted.'
  end

  private

  def payment_params
    params.require(:payment).permit(:donation_id, :amount, :payment_date, :payment_method, :status, :transaction_id)
  end
end
