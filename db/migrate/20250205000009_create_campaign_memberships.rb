class CreateCampaignMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :campaign_memberships do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :contact,  null: false, foreign_key: true

      t.integer    :status,        default: 0          # enum: sent, responded, attended, no_show
      t.date       :first_responded_date

      t.timestamps
    end

    add_index :campaign_memberships, [:campaign_id, :contact_id], unique: true
  end
end
