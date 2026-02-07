class AffiliationsController < ApplicationController
  before_action :set_affiliation, only: [:show, :edit, :update, :destroy]
  before_action :load_associations, only: [:new, :edit, :create, :update]

  def index
    @affiliations = Affiliation.includes(:contact, :organization).order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
  end

  def new
    @affiliation = Affiliation.new
  end

  def edit
  end

  def create
    @affiliation = Affiliation.new(affiliation_params)
    if @affiliation.save
      redirect_to affiliations_path, notice: 'Affiliation was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @affiliation.update(affiliation_params)
      redirect_to affiliations_path, notice: 'Affiliation was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @affiliation.destroy
    redirect_to affiliations_path, notice: 'Affiliation was successfully deleted.'
  end

  private

  def set_affiliation
    @affiliation = Affiliation.find(params[:id])
  end

  def load_associations
    @contacts = Contact.order(:last_name, :first_name)
    @organizations = Account.where(account_type: 'organization').order(:name)
  end

  def affiliation_params
    params.require(:affiliation).permit(
      :contact_id, :organization_id, :role, :status, :primary,
      :start_date, :end_date, :description
    )
  end
end
