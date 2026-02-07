class ContactsController < ApplicationController
  def index
    @contacts = Contact.includes(:account).order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
    @contact = Contact.find(params[:id])
  end

  def new
    @contact = Contact.new
  end

  def edit
    @contact = Contact.find(params[:id])
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
    @contact = Contact.find(params[:id])
    if @contact.update(contact_params)
      redirect_to @contact, notice: 'Contact was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy
    redirect_to contacts_url, notice: 'Contact was successfully deleted.'
  end

  private

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :email, :phone, :mobile, :account_id, :title, :birthdate)
  end
end
