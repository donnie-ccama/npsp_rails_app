class CreateDonations < ActiveRecord::Migration[7.1]
  def change
    create_table :donations do |t|
      t.string     :name                               # auto-named: "Smith Household 01/2025 Donation"

      # --- Core relationships ---
      t.references :account,            foreign_key: true, null: true  # Household Account
      t.references :contact,            foreign_key: true, null: true  # Primary donor (Contact)
      t.references :campaign,           foreign_key: true, null: true  # Source campaign
      t.references :recurring_donation, foreign_key: true, null: true  # Parent if installment

      # --- Donation details ---
      t.decimal    :amount,        precision: 15, scale: 2
      t.date       :close_date,    null: false            # date received (or expected)
      t.integer    :stage,         null: false, default: 0 # enum: pledged, posted, received, closed_lost, thanked
      t.decimal    :probability,   precision: 5, scale: 2, default: 100.0
      t.string     :record_type                         # Donation, Grant, In-Kind, Major Gift, Matching, Membership
      t.string     :donation_type                       # New, Renewed, Upgraded, Downgraded
      t.string     :lead_source                         # Web, Direct Mail, Event, Phone, etc.
      t.string     :next_step
      t.text       :description

      # --- NPSP Gift fields ---
      t.integer    :gift_type,     default: 0            # enum: cash, check, credit_card, wire, stock, in_kind, crypto
      t.integer    :acknowledgment_status, default: 0    # enum: to_be_acknowledged, acknowledged, do_not_acknowledge, email_sent
      t.date       :acknowledgment_date

      # --- Tribute fields ---
      t.integer    :tribute_type                        # enum: nil, in_honor_of, in_memory_of
      t.string     :honoree_name
      t.references :honoree_contact,           foreign_key: { to_table: :contacts }, null: true
      t.references :notification_recipient,    foreign_key: { to_table: :contacts }, null: true

      # --- Matching gift fields ---
      t.integer    :matching_gift_status                # enum: nil, potential, submitted, received, not_applicable
      t.references :matching_gift_account,     foreign_key: { to_table: :accounts }, null: true
      t.references :matching_gift_donation,    foreign_key: { to_table: :donations }, null: true

      # --- Computed flags ---
      t.boolean    :is_closed,     default: false
      t.boolean    :is_won,        default: false

      t.timestamps
    end

    add_index :donations, :stage
    add_index :donations, :close_date
    add_index :donations, :is_closed
    add_index :donations, :is_won
    add_index :donations, [:account_id, :close_date]
    add_index :donations, [:contact_id, :close_date]
  end
end
