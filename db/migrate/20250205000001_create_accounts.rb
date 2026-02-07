class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      # --- Core identity ---
      t.string   :name,           null: false          # "Smith Household" or "Acme Foundation"
      t.integer  :account_type,   null: false, default: 0  # enum: household, organization
      t.string   :record_type                          # optional sub-type: Foundation, Corporation, Government, etc.

      # --- Contact info ---
      t.string   :phone
      t.string   :fax
      t.string   :website

      # --- Billing / Mailing address (synced from NPSP Address object) ---
      t.string   :billing_street
      t.string   :billing_city
      t.string   :billing_state
      t.string   :billing_postal_code
      t.string   :billing_country

      # --- Shipping address (for organizations) ---
      t.string   :shipping_street
      t.string   :shipping_city
      t.string   :shipping_state
      t.string   :shipping_postal_code
      t.string   :shipping_country

      # --- Organization-specific fields ---
      t.string   :industry
      t.decimal  :annual_revenue,  precision: 15, scale: 2
      t.integer  :number_of_employees

      # --- Household-specific fields (NPSP) ---
      t.string   :formal_greeting                      # "Mr. John and Mrs. Jane Smith"
      t.string   :informal_greeting                    # "John and Jane"

      # --- Hierarchy ---
      t.references :parent_account, foreign_key: { to_table: :accounts }, null: true

      # --- Ownership ---
      t.text     :description

      # --- NPSP Rollup fields (updated by callbacks) ---
      t.decimal  :total_gifts,           precision: 15, scale: 2, default: 0
      t.integer  :number_of_gifts,       default: 0
      t.decimal  :average_gift,          precision: 15, scale: 2, default: 0
      t.decimal  :largest_gift,          precision: 15, scale: 2, default: 0
      t.decimal  :smallest_gift,         precision: 15, scale: 2
      t.date     :first_gift_date
      t.date     :last_gift_date
      t.decimal  :last_gift_amount,      precision: 15, scale: 2
      t.decimal  :total_gifts_this_year, precision: 15, scale: 2, default: 0
      t.decimal  :total_gifts_last_year, precision: 15, scale: 2, default: 0
      t.string   :best_gift_year
      t.decimal  :best_gift_year_total,  precision: 15, scale: 2

      t.timestamps
    end

    add_index :accounts, :account_type
    add_index :accounts, :name
  end
end
