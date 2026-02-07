class CreateContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :contacts do |t|
      # --- Core identity ---
      t.string     :first_name
      t.string     :last_name,    null: false
      t.string     :salutation                         # Mr., Mrs., Ms., Dr.
      t.string     :title                              # Job title
      t.string     :department

      # --- Account (Household) ---
      t.references :account, foreign_key: true          # auto-assigned Household Account

      # --- Email fields (NPSP adds multiple emails) ---
      t.string     :email                              # primary email (synced from preferred)
      t.string     :personal_email
      t.string     :work_email
      t.string     :alternate_email
      t.integer    :preferred_email, default: 0         # enum: personal, work, alternate

      # --- Phone fields (NPSP adds multiple phones) ---
      t.string     :phone                              # primary phone (synced from preferred)
      t.string     :home_phone
      t.string     :mobile_phone
      t.string     :work_phone
      t.string     :other_phone
      t.integer    :preferred_phone, default: 0         # enum: home, work, mobile, other

      # --- Mailing address (synced from NPSP Address object) ---
      t.string     :mailing_street
      t.string     :mailing_city
      t.string     :mailing_state
      t.string     :mailing_postal_code
      t.string     :mailing_country

      # --- Personal info ---
      t.date       :birthdate
      t.string     :lead_source                        # Web, Event, Referral, Direct Mail, etc.

      # --- NPSP-specific flags ---
      t.boolean    :deceased,           default: false  # exclude from rollups and mailings
      t.boolean    :do_not_contact,     default: false  # master opt-out
      t.boolean    :do_not_call,        default: false
      t.boolean    :email_opt_out,      default: false

      # --- Organizational affiliation ---
      t.references :primary_affiliation, foreign_key: { to_table: :accounts }, null: true

      # --- Donor level (auto-assigned by Levels feature) ---
      t.string     :donor_level                        # Bronze, Silver, Gold, etc.

      # --- Notes ---
      t.text       :description

      # --- NPSP Rollup fields (updated by callbacks) ---
      t.decimal    :total_gifts,              precision: 15, scale: 2, default: 0
      t.integer    :number_of_gifts,          default: 0
      t.decimal    :average_gift,             precision: 15, scale: 2, default: 0
      t.decimal    :largest_gift,             precision: 15, scale: 2, default: 0
      t.decimal    :smallest_gift,            precision: 15, scale: 2
      t.date       :first_gift_date
      t.date       :last_gift_date
      t.decimal    :last_gift_amount,         precision: 15, scale: 2
      t.decimal    :total_gifts_this_year,    precision: 15, scale: 2, default: 0
      t.decimal    :total_gifts_last_year,    precision: 15, scale: 2, default: 0
      t.decimal    :total_soft_credits,       precision: 15, scale: 2, default: 0
      t.integer    :number_of_soft_credits,   default: 0
      t.integer    :consecutive_giving_years, default: 0
      t.string     :best_gift_year
      t.decimal    :best_gift_year_total,     precision: 15, scale: 2

      t.timestamps
    end

    add_index :contacts, :last_name
    add_index :contacts, :email
    add_index :contacts, [:last_name, :first_name]
  end
end
