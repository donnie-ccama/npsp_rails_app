class SearchController < ApplicationController
  def index
    @query = params[:q]
    
    if @query.present?
      # Search contacts by name or email
      @contacts = Contact.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR personal_email ILIKE ? OR work_email ILIKE ?",
        "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%"
      ).includes(:account).limit(20)
      
      # Search accounts by name
      @accounts = Account.where("name ILIKE ?", "%#{@query}%").limit(20)
    else
      @contacts = Contact.none
      @accounts = Account.none
    end
  end
end
