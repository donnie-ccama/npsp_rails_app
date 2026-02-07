class CreateGauAllocations < ActiveRecord::Migration[7.1]
  def change
    create_table :gau_allocations do |t|
      # --- The fund ---
      t.references :general_accounting_unit, null: false, foreign_key: true

      # --- What it's allocated to (one of these is required) ---
      t.references :donation,           foreign_key: true, null: true
      t.references :recurring_donation, foreign_key: true, null: true
      t.references :campaign,           foreign_key: true, null: true

      # --- Amount or percentage (use one) ---
      t.decimal    :amount,   precision: 15, scale: 2   # dollar amount allocated
      t.decimal    :percent,  precision: 5, scale: 2     # percentage allocated (0-100)

      t.timestamps
    end

    add_index :gau_allocations, [:general_accounting_unit_id, :donation_id],
              name: "idx_gau_alloc_on_gau_and_donation"
  end
end
