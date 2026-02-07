class CreateAffiliations < ActiveRecord::Migration[7.1]
  def change
    create_table :affiliations do |t|
      t.references :contact,      null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: { to_table: :accounts }

      t.string     :role                               # Employee, Board Member, Volunteer, Student, Faculty
      t.integer    :status,       default: 0           # enum: current, former
      t.boolean    :primary,      default: false       # sets contact.primary_affiliation
      t.date       :start_date
      t.date       :end_date
      t.text       :description

      t.timestamps
    end

    add_index :affiliations, [:contact_id, :organization_id]
  end
end
