class CreateRelationships < ActiveRecord::Migration[7.1]
  def change
    create_table :relationships do |t|
      t.references :contact,         null: false, foreign_key: true
      t.references :related_contact, null: false, foreign_key: { to_table: :contacts }

      t.string     :relationship_type, null: false     # Spouse, Parent, Child, Sibling, Friend, Colleague
      t.integer    :status,            default: 0      # enum: current, former
      t.text       :description

      # --- Reciprocal link (NPSP auto-creates the inverse) ---
      t.references :reciprocal_relationship, foreign_key: { to_table: :relationships }, null: true

      t.timestamps
    end

    add_index :relationships, [:contact_id, :related_contact_id]
  end
end
