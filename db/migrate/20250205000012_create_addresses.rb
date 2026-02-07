class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.references :account, null: false, foreign_key: true  # Household Account

      t.string     :street
      t.string     :city
      t.string     :state
      t.string     :postal_code
      t.string     :country
      t.integer    :address_type,   default: 0         # enum: home, work, other, seasonal
      t.boolean    :default_address, default: false     # syncs to Account + Contact mailing fields
      t.integer    :seasonal_start_month               # 1-12 (for seasonal addresses)
      t.integer    :seasonal_start_day                  # 1-31
      t.integer    :seasonal_end_month
      t.integer    :seasonal_end_day
      t.boolean    :verified,       default: false      # set by address verification service

      t.timestamps
    end

    add_index :addresses, [:account_id, :default_address]
  end
end
