# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_02_05_000018) do
  create_table "account_soft_credits", force: :cascade do |t|
    t.integer "account_id", null: false
    t.decimal "amount", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.integer "donation_id", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_soft_credits_on_account_id"
    t.index ["donation_id"], name: "index_account_soft_credits_on_donation_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "account_type", default: 0, null: false
    t.decimal "annual_revenue", precision: 15, scale: 2
    t.decimal "average_gift", precision: 15, scale: 2, default: "0.0"
    t.string "best_gift_year"
    t.decimal "best_gift_year_total", precision: 15, scale: 2
    t.string "billing_city"
    t.string "billing_country"
    t.string "billing_postal_code"
    t.string "billing_state"
    t.string "billing_street"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "fax"
    t.date "first_gift_date"
    t.string "formal_greeting"
    t.string "industry"
    t.string "informal_greeting"
    t.decimal "largest_gift", precision: 15, scale: 2, default: "0.0"
    t.decimal "last_gift_amount", precision: 15, scale: 2
    t.date "last_gift_date"
    t.string "name", null: false
    t.integer "number_of_employees"
    t.integer "number_of_gifts", default: 0
    t.integer "parent_account_id"
    t.string "phone"
    t.string "record_type"
    t.string "shipping_city"
    t.string "shipping_country"
    t.string "shipping_postal_code"
    t.string "shipping_state"
    t.string "shipping_street"
    t.decimal "smallest_gift", precision: 15, scale: 2
    t.decimal "total_gifts", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_gifts_last_year", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_gifts_this_year", precision: 15, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["account_type"], name: "index_accounts_on_account_type"
    t.index ["name"], name: "index_accounts_on_name"
    t.index ["parent_account_id"], name: "index_accounts_on_parent_account_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "address_type", default: 0
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.boolean "default_address", default: false
    t.string "postal_code"
    t.integer "seasonal_end_day"
    t.integer "seasonal_end_month"
    t.integer "seasonal_start_day"
    t.integer "seasonal_start_month"
    t.string "state"
    t.string "street"
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false
    t.index ["account_id", "default_address"], name: "index_addresses_on_account_id_and_default_address"
    t.index ["account_id"], name: "index_addresses_on_account_id"
  end

  create_table "affiliations", force: :cascade do |t|
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_date"
    t.integer "organization_id", null: false
    t.boolean "primary", default: false
    t.string "role"
    t.date "start_date"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["contact_id", "organization_id"], name: "index_affiliations_on_contact_id_and_organization_id"
    t.index ["contact_id"], name: "index_affiliations_on_contact_id"
    t.index ["organization_id"], name: "index_affiliations_on_organization_id"
  end

  create_table "campaign_memberships", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.date "first_responded_date"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "contact_id"], name: "index_campaign_memberships_on_campaign_id_and_contact_id", unique: true
    t.index ["campaign_id"], name: "index_campaign_memberships_on_campaign_id"
    t.index ["contact_id"], name: "index_campaign_memberships_on_contact_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.boolean "active", default: true
    t.decimal "actual_cost", precision: 15, scale: 2
    t.decimal "budgeted_cost", precision: 15, scale: 2
    t.integer "campaign_type", default: 0
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_date"
    t.decimal "expected_response", precision: 5, scale: 2
    t.decimal "expected_revenue", precision: 15, scale: 2
    t.string "name", null: false
    t.integer "number_sent", default: 0
    t.integer "parent_campaign_id"
    t.date "start_date"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_campaigns_on_active"
    t.index ["parent_campaign_id"], name: "index_campaigns_on_parent_campaign_id"
    t.index ["status"], name: "index_campaigns_on_status"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer "account_id"
    t.string "alternate_email"
    t.decimal "average_gift", precision: 15, scale: 2, default: "0.0"
    t.string "best_gift_year"
    t.decimal "best_gift_year_total", precision: 15, scale: 2
    t.date "birthdate"
    t.integer "consecutive_giving_years", default: 0
    t.datetime "created_at", null: false
    t.boolean "deceased", default: false
    t.string "department"
    t.text "description"
    t.boolean "do_not_call", default: false
    t.boolean "do_not_contact", default: false
    t.string "donor_level"
    t.string "email"
    t.boolean "email_opt_out", default: false
    t.date "first_gift_date"
    t.string "first_name"
    t.string "home_phone"
    t.decimal "largest_gift", precision: 15, scale: 2, default: "0.0"
    t.decimal "last_gift_amount", precision: 15, scale: 2
    t.date "last_gift_date"
    t.string "last_name", null: false
    t.string "lead_source"
    t.string "mailing_city"
    t.string "mailing_country"
    t.string "mailing_postal_code"
    t.string "mailing_state"
    t.string "mailing_street"
    t.string "mobile_phone"
    t.integer "number_of_gifts", default: 0
    t.integer "number_of_soft_credits", default: 0
    t.string "other_phone"
    t.string "personal_email"
    t.string "phone"
    t.integer "preferred_email", default: 0
    t.integer "preferred_phone", default: 0
    t.integer "primary_affiliation_id"
    t.string "salutation"
    t.decimal "smallest_gift", precision: 15, scale: 2
    t.string "title"
    t.decimal "total_gifts", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_gifts_last_year", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_gifts_this_year", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_soft_credits", precision: 15, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.string "work_email"
    t.string "work_phone"
    t.index ["account_id"], name: "index_contacts_on_account_id"
    t.index ["email"], name: "index_contacts_on_email"
    t.index ["last_name", "first_name"], name: "index_contacts_on_last_name_and_first_name"
    t.index ["last_name"], name: "index_contacts_on_last_name"
    t.index ["primary_affiliation_id"], name: "index_contacts_on_primary_affiliation_id"
  end

  create_table "donation_contact_roles", force: :cascade do |t|
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.integer "donation_id", null: false
    t.boolean "is_primary", default: false
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_donation_contact_roles_on_contact_id"
    t.index ["donation_id", "contact_id", "role"], name: "idx_dcr_unique_role", unique: true
    t.index ["donation_id"], name: "index_donation_contact_roles_on_donation_id"
  end

  create_table "donations", force: :cascade do |t|
    t.integer "account_id"
    t.date "acknowledgment_date"
    t.integer "acknowledgment_status", default: 0
    t.decimal "amount", precision: 15, scale: 2
    t.integer "campaign_id"
    t.date "close_date", null: false
    t.integer "contact_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "donation_type"
    t.integer "gift_type", default: 0
    t.integer "honoree_contact_id"
    t.string "honoree_name"
    t.boolean "is_closed", default: false
    t.boolean "is_won", default: false
    t.string "lead_source"
    t.integer "matching_gift_account_id"
    t.integer "matching_gift_donation_id"
    t.integer "matching_gift_status"
    t.string "name"
    t.string "next_step"
    t.integer "notification_recipient_id"
    t.decimal "probability", precision: 5, scale: 2, default: "100.0"
    t.string "record_type"
    t.integer "recurring_donation_id"
    t.integer "stage", default: 0, null: false
    t.integer "tribute_type"
    t.datetime "updated_at", null: false
    t.index ["account_id", "close_date"], name: "index_donations_on_account_id_and_close_date"
    t.index ["account_id"], name: "index_donations_on_account_id"
    t.index ["campaign_id"], name: "index_donations_on_campaign_id"
    t.index ["close_date"], name: "index_donations_on_close_date"
    t.index ["contact_id", "close_date"], name: "index_donations_on_contact_id_and_close_date"
    t.index ["contact_id"], name: "index_donations_on_contact_id"
    t.index ["honoree_contact_id"], name: "index_donations_on_honoree_contact_id"
    t.index ["is_closed"], name: "index_donations_on_is_closed"
    t.index ["is_won"], name: "index_donations_on_is_won"
    t.index ["matching_gift_account_id"], name: "index_donations_on_matching_gift_account_id"
    t.index ["matching_gift_donation_id"], name: "index_donations_on_matching_gift_donation_id"
    t.index ["notification_recipient_id"], name: "index_donations_on_notification_recipient_id"
    t.index ["recurring_donation_id"], name: "index_donations_on_recurring_donation_id"
    t.index ["stage"], name: "index_donations_on_stage"
  end

  create_table "donor_levels", force: :cascade do |t|
    t.string "applies_to", default: "contact"
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "maximum_amount", precision: 15, scale: 2
    t.decimal "minimum_amount", precision: 15, scale: 2, null: false
    t.string "name", null: false
    t.integer "sort_order", default: 0
    t.string "source_field", default: "total_gifts"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_donor_levels_on_name", unique: true
    t.index ["sort_order"], name: "index_donor_levels_on_sort_order"
  end

  create_table "engagement_plan_tasks", force: :cascade do |t|
    t.string "assigned_to_type"
    t.text "comments"
    t.datetime "created_at", null: false
    t.integer "days_after", default: 0
    t.integer "engagement_plan_template_id", null: false
    t.integer "priority", default: 0
    t.string "subject", null: false
    t.string "task_type"
    t.datetime "updated_at", null: false
    t.index ["engagement_plan_template_id"], name: "index_engagement_plan_tasks_on_engagement_plan_template_id"
  end

  create_table "engagement_plan_templates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.boolean "reschedule_to", default: false
    t.boolean "skip_weekends", default: true
    t.datetime "updated_at", null: false
  end

  create_table "engagement_plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "engagement_plan_template_id", null: false
    t.bigint "plannable_id"
    t.string "plannable_type"
    t.date "start_date"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["engagement_plan_template_id"], name: "index_engagement_plans_on_engagement_plan_template_id"
    t.index ["plannable_type", "plannable_id"], name: "index_engagement_plans_on_plannable_type_and_plannable_id"
  end

  create_table "gau_allocations", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2
    t.integer "campaign_id"
    t.datetime "created_at", null: false
    t.integer "donation_id"
    t.integer "general_accounting_unit_id", null: false
    t.decimal "percent", precision: 5, scale: 2
    t.integer "recurring_donation_id"
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_gau_allocations_on_campaign_id"
    t.index ["donation_id"], name: "index_gau_allocations_on_donation_id"
    t.index ["general_accounting_unit_id", "donation_id"], name: "idx_gau_alloc_on_gau_and_donation"
    t.index ["general_accounting_unit_id"], name: "index_gau_allocations_on_general_accounting_unit_id"
    t.index ["recurring_donation_id"], name: "index_gau_allocations_on_recurring_donation_id"
  end

  create_table "general_accounting_units", force: :cascade do |t|
    t.boolean "active", default: true
    t.decimal "average_allocation", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.text "description"
    t.date "first_allocation_date"
    t.decimal "largest_allocation", precision: 15, scale: 2
    t.date "last_allocation_date"
    t.string "name", null: false
    t.decimal "smallest_allocation", precision: 15, scale: 2
    t.decimal "total_allocations", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_allocations_last_year", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_allocations_this_year", precision: 15, scale: 2, default: "0.0"
    t.integer "total_number_of_allocations", default: 0
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_general_accounting_units_on_active"
    t.index ["name"], name: "index_general_accounting_units_on_name", unique: true
  end

  create_table "partial_soft_credits", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.integer "donation_id", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_partial_soft_credits_on_contact_id"
    t.index ["donation_id"], name: "index_partial_soft_credits_on_donation_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2
    t.string "check_reference_number"
    t.datetime "created_at", null: false
    t.integer "donation_id", null: false
    t.boolean "paid", default: false
    t.date "payment_date"
    t.integer "payment_method", default: 0
    t.date "scheduled_date"
    t.datetime "updated_at", null: false
    t.boolean "written_off", default: false
    t.index ["donation_id"], name: "index_payments_on_donation_id"
    t.index ["paid"], name: "index_payments_on_paid"
    t.index ["scheduled_date"], name: "index_payments_on_scheduled_date"
  end

  create_table "recurring_donations", force: :cascade do |t|
    t.integer "account_id"
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.integer "campaign_id"
    t.integer "contact_id"
    t.datetime "created_at", null: false
    t.decimal "current_year_value", precision: 15, scale: 2, default: "0.0"
    t.date "date_established"
    t.integer "day_of_month", default: 1
    t.date "effective_date"
    t.integer "installment_period", default: 0, null: false
    t.string "name"
    t.date "next_donation_date"
    t.decimal "next_year_value", precision: 15, scale: 2, default: "0.0"
    t.integer "payment_method", default: 0
    t.integer "planned_installments"
    t.integer "recurring_type", default: 0, null: false
    t.date "start_date", null: false
    t.integer "status", default: 0, null: false
    t.string "status_reason"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_recurring_donations_on_account_id"
    t.index ["campaign_id"], name: "index_recurring_donations_on_campaign_id"
    t.index ["contact_id"], name: "index_recurring_donations_on_contact_id"
    t.index ["next_donation_date"], name: "index_recurring_donations_on_next_donation_date"
    t.index ["status"], name: "index_recurring_donations_on_status"
  end

  create_table "relationships", force: :cascade do |t|
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "reciprocal_relationship_id"
    t.integer "related_contact_id", null: false
    t.string "relationship_type", null: false
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["contact_id", "related_contact_id"], name: "index_relationships_on_contact_id_and_related_contact_id"
    t.index ["contact_id"], name: "index_relationships_on_contact_id"
    t.index ["reciprocal_relationship_id"], name: "index_relationships_on_reciprocal_relationship_id"
    t.index ["related_contact_id"], name: "index_relationships_on_related_contact_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "assigned_to"
    t.integer "contact_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.boolean "is_closed", default: false
    t.integer "priority", default: 1
    t.integer "status", default: 0
    t.string "subject"
    t.string "task_type"
    t.bigint "taskable_id"
    t.string "taskable_type"
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_tasks_on_contact_id"
    t.index ["due_date"], name: "index_tasks_on_due_date"
    t.index ["status"], name: "index_tasks_on_status"
    t.index ["taskable_type", "taskable_id"], name: "index_tasks_on_taskable_type_and_taskable_id"
  end

  add_foreign_key "account_soft_credits", "accounts"
  add_foreign_key "account_soft_credits", "donations"
  add_foreign_key "accounts", "accounts", column: "parent_account_id"
  add_foreign_key "addresses", "accounts"
  add_foreign_key "affiliations", "accounts", column: "organization_id"
  add_foreign_key "affiliations", "contacts"
  add_foreign_key "campaign_memberships", "campaigns"
  add_foreign_key "campaign_memberships", "contacts"
  add_foreign_key "campaigns", "campaigns", column: "parent_campaign_id"
  add_foreign_key "contacts", "accounts"
  add_foreign_key "contacts", "accounts", column: "primary_affiliation_id"
  add_foreign_key "donation_contact_roles", "contacts"
  add_foreign_key "donation_contact_roles", "donations"
  add_foreign_key "donations", "accounts"
  add_foreign_key "donations", "accounts", column: "matching_gift_account_id"
  add_foreign_key "donations", "campaigns"
  add_foreign_key "donations", "contacts"
  add_foreign_key "donations", "contacts", column: "honoree_contact_id"
  add_foreign_key "donations", "contacts", column: "notification_recipient_id"
  add_foreign_key "donations", "donations", column: "matching_gift_donation_id"
  add_foreign_key "donations", "recurring_donations"
  add_foreign_key "engagement_plan_tasks", "engagement_plan_templates"
  add_foreign_key "engagement_plans", "engagement_plan_templates"
  add_foreign_key "gau_allocations", "campaigns"
  add_foreign_key "gau_allocations", "donations"
  add_foreign_key "gau_allocations", "general_accounting_units"
  add_foreign_key "gau_allocations", "recurring_donations"
  add_foreign_key "partial_soft_credits", "contacts"
  add_foreign_key "partial_soft_credits", "donations"
  add_foreign_key "payments", "donations"
  add_foreign_key "recurring_donations", "accounts"
  add_foreign_key "recurring_donations", "campaigns"
  add_foreign_key "recurring_donations", "contacts"
  add_foreign_key "relationships", "contacts"
  add_foreign_key "relationships", "contacts", column: "related_contact_id"
  add_foreign_key "relationships", "relationships", column: "reciprocal_relationship_id"
  add_foreign_key "tasks", "contacts"
end
