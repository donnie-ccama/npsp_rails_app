class WelcomeController < ApplicationController
  def index
    # Initialize all variables with defaults
    @db_status = "Unknown"
    @db_error = nil
    @total_contacts = 0
    @total_donations_amount = 0
    @recurring_donations_count = 0
    @household_count = 0
    @donation_types = {}
    @donation_frequencies = {}
    @recent_donations_amount = 0
    @recent_donations_count = 0

    # Database connection check
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      @db_status = "Connected! (Safe to use)"
      
      # Only run queries if database is connected
      # Wrap each in individual rescue blocks to prevent one failure from breaking everything
      begin
        @total_contacts = Contact.count
      rescue => e
        Rails.logger.error "Failed to count contacts: #{e.message}"
      end

      begin
        @total_donations_amount = Donation.sum(:amount) || 0
      rescue => e
        Rails.logger.error "Failed to sum donations: #{e.message}"
      end

      begin
        @recurring_donations_count = RecurringDonation.count
      rescue => e
        Rails.logger.error "Failed to count recurring donations: #{e.message}"
      end
      
      begin
        @household_count = Account.household.count
      rescue => e
        Rails.logger.error "Failed to count households: #{e.message}"
      end
      
      begin
        @donation_types = Donation.group(:donation_type).count
      rescue => e
        Rails.logger.error "Failed to group donation types: #{e.message}"
      end
      
      begin
        @donation_frequencies = RecurringDonation.group(:frequency).count
      rescue => e
        Rails.logger.error "Failed to group donation frequencies: #{e.message}"
      end
      
      begin
        thirty_days_ago = 30.days.ago
        @recent_donations_amount = Donation.where('created_at >= ?', thirty_days_ago).sum(:amount)
        @recent_donations_count = Donation.where('created_at >= ?', thirty_days_ago).count
      rescue => e
        Rails.logger.error "Failed to calculate recent donations: #{e.message}"
      end
      
    rescue => e
      @db_status = "Connection Failed"
      @db_error = e.message
      Rails.logger.error "Database connection failed: #{e.message}"
    end
  end
end
