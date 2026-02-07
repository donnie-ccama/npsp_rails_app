class CreateRecurringDonations < ActiveRecord::Migration[7.1]
  def change
    create_table :recurring_donations do |t|
      t.string     :name                               # auto-generated: "RD-0001"

      # --- Donor (one of these is required) ---
      t.references :contact,      foreign_key: true, null: true   # individual donor
      t.references :account,      foreign_key: true, null: true   # organizational donor

      # --- Schedule ---
      t.decimal    :amount,              null: false, precision: 15, scale: 2
      t.integer    :recurring_type,      null: false, default: 0  # enum: open_ended, fixed
      t.integer    :installment_period,  null: false, default: 0  # enum: monthly, quarterly, yearly, weekly, bimonthly
      t.integer    :day_of_month,        default: 1               # 1-28 or 31 for last day
      t.date       :start_date,          null: false
      t.date       :effective_date                     # date of last schedule/amount change
      t.date       :date_established                   # when first created
      t.integer    :planned_installments               # only for fixed type

      # --- Status ---
      t.integer    :status,          null: false, default: 0  # enum: active, lapsed, closed, paused
      t.string     :status_reason                      # Financial Difficulty, No Longer Interested, etc.

      # --- Payment info ---
      t.integer    :payment_method,  default: 0        # enum: credit_card, check, ach, cash

      # --- Campaign ---
      t.references :campaign, foreign_key: true, null: true

      # --- Calculated fields ---
      t.date       :next_donation_date                 # calculated from schedule
      t.decimal    :current_year_value,  precision: 15, scale: 2, default: 0
      t.decimal    :next_year_value,     precision: 15, scale: 2, default: 0

      t.timestamps
    end

    add_index :recurring_donations, :status
    add_index :recurring_donations, :next_donation_date
  end
end
