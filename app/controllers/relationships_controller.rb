class RelationshipsController < ApplicationController
  before_action :set_relationship, only: [:show, :edit, :update, :destroy]
  before_action :load_contacts, only: [:new, :edit, :create, :update]

  def index
    @relationships = Relationship.includes(:contact, :related_contact).order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
  end

  def new
    @relationship = Relationship.new
  end

  def edit
  end

  def create
    @relationship = Relationship.new(relationship_params)
    if @relationship.save
      redirect_to relationships_path, notice: 'Relationship was successfully created. Reciprocal relationship also created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @relationship.update(relationship_params)
      redirect_to relationships_path, notice: 'Relationship was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @relationship.destroy
    redirect_to relationships_path, notice: 'Relationship and its reciprocal were successfully deleted.'
  end

  private

  def set_relationship
    @relationship = Relationship.find(params[:id])
  end

  def load_contacts
    @contacts = Contact.order(:last_name, :first_name)
  end

  def relationship_params
    params.require(:relationship).permit(
      :contact_id, :related_contact_id, :relationship_type, :status, :description
    )
  end
end
