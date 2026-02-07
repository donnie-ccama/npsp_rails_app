class WelcomeController < ApplicationController
  def index
    # Database connection check
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      @db_status = "Connected! (Safe to use)"
      @db_error = nil
    rescue => e
      @db_status = "Connection Failed"
      @db_error = e.message
    end

    # Calculate metrics
    @total_contacts = Contact.count
    @total_donations_amount = Donation.sum(:amount) || 0
    @recurring_donations_count = RecurringDonation.count
    
    # Household count (accounts that are households)
    @household_count = Account.where(account_type: 'Household').count rescue 0
    
    # Donation type breakdown
    @donation_types = Donation.group(:donation_type).count rescue {}
    
    # Donation frequency for recurring donations
    @donation_frequencies = RecurringDonation.group(:frequency).count rescue {}
    
    # Recent donations (last 30 days)
    thirty_days_ago = 30.days.ago
    @recent_donations_amount = Donation.where('created_at >= ?', thirty_days_ago).sum(:amount) rescue 0
    @recent_donations_count = Donation.where('created_at >= ?', thirty_days_ago).count rescue 0
  end
end
