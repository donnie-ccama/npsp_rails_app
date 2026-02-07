class CreateDonationContactRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :donation_contact_roles do |t|
      t.references :donation, null: false, foreign_key: true
      t.references :contact,  null: false, foreign_key: true

      t.string     :role,         null: false          # Donor, Soft Credit, Solicitor, Honoree, Influencer
      t.boolean    :is_primary,   default: false       # the main donor on this gift

      t.timestamps
    end

    add_index :donation_contact_roles, [:donation_id, :contact_id, :role],
              unique: true, name: "idx_dcr_unique_role"
  end
end
