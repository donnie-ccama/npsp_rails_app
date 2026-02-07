class CreateDonorLevels < ActiveRecord::Migration[7.1]
  def change
    create_table :donor_levels do |t|
      t.string     :name,            null: false       # "Bronze", "Silver", "Gold", "Platinum"
      t.decimal    :minimum_amount,  precision: 15, scale: 2, null: false  # minimum giving threshold
      t.decimal    :maximum_amount,  precision: 15, scale: 2               # upper bound (nil = no limit)
      t.string     :applies_to,      default: "contact"  # "contact" or "account"
      t.string     :source_field,    default: "total_gifts" # which rollup field to evaluate
      t.text       :description
      t.integer    :sort_order,      default: 0

      t.timestamps
    end

    add_index :donor_levels, :name, unique: true
    add_index :donor_levels, :sort_order
  end
end
