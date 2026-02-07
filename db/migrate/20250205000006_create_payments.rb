class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      # --- Master-Detail to Donation (cascade delete) ---
      t.references :donation, null: false, foreign_key: true

      t.decimal    :amount,           precision: 15, scale: 2
      t.date       :payment_date                       # when actually received
      t.date       :scheduled_date                     # when expected (for pledge schedules)
      t.boolean    :paid,             default: false
      t.integer    :payment_method,   default: 0       # enum: cash, check, credit_card, ach, wire, stock
      t.string     :check_reference_number
      t.boolean    :written_off,      default: false   # for uncollectible pledges

      t.timestamps
    end

    add_index :payments, :paid
    add_index :payments, :scheduled_date
  end
end
