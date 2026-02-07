class CreateGeneralAccountingUnits < ActiveRecord::Migration[7.1]
  def change
    create_table :general_accounting_units do |t|
      t.string     :name,           null: false        # "General Fund", "Meals Program", "Capital Campaign"
      t.boolean    :active,          default: true
      t.text       :description

      # --- NPSP Rollup fields (updated by callbacks) ---
      t.decimal    :total_allocations,           precision: 15, scale: 2, default: 0
      t.integer    :total_number_of_allocations, default: 0
      t.decimal    :largest_allocation,          precision: 15, scale: 2
      t.decimal    :smallest_allocation,         precision: 15, scale: 2
      t.decimal    :average_allocation,          precision: 15, scale: 2
      t.date       :first_allocation_date
      t.date       :last_allocation_date
      t.decimal    :total_allocations_this_year, precision: 15, scale: 2, default: 0
      t.decimal    :total_allocations_last_year, precision: 15, scale: 2, default: 0

      t.timestamps
    end

    add_index :general_accounting_units, :active
    add_index :general_accounting_units, :name, unique: true
  end
end
