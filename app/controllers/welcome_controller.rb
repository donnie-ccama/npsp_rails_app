class WelcomeController < ApplicationController
  def index
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      @db_status = "Connected! (Safe to use)"
      @db_error = nil
    rescue => e
      @db_status = "Connection Failed"
      @db_error = e.message
    end
  end
end
