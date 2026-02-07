class CreateCampaigns < ActiveRecord::Migration[7.1]
  def change
    create_table :campaigns do |t|
      t.string     :name,              null: false
      t.integer    :campaign_type,     default: 0       # enum: email, direct_mail, event, webinar, advertisement, other
      t.integer    :status,            default: 0       # enum: planned, in_progress, completed, aborted
      t.date       :start_date
      t.date       :end_date
      t.decimal    :expected_revenue,  precision: 15, scale: 2
      t.decimal    :budgeted_cost,     precision: 15, scale: 2
      t.decimal    :actual_cost,       precision: 15, scale: 2
      t.decimal    :expected_response, precision: 5, scale: 2  # percentage
      t.integer    :number_sent,       default: 0
      t.boolean    :active,            default: true
      t.text       :description

      # --- Hierarchy ---
      t.references :parent_campaign, foreign_key: { to_table: :campaigns }, null: true

      t.timestamps
    end

    add_index :campaigns, :status
    add_index :campaigns, :active
  end
end
