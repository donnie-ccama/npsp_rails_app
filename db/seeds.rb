# db/seeds.rb
#
# This file shows how all the models work together.
# Run with:  rails db:seed
#
# It creates sample data that mirrors how Citychurch might use the CRM.
#

puts "🌱 Seeding NPSP-style CRM data..."

# ============================================================
# 1. CREATE FUNDS (GAUs)
#    These represent the programs/funds you track donations against.
# ============================================================
general_fund = GeneralAccountingUnit.create!(
  name: "General Fund",
  description: "Unrestricted funds for general operations",
  active: true
)

meals_program = GeneralAccountingUnit.create!(
  name: "Meals Program",
  description: "Feeding hungry children in the Texas Panhandle",
  active: true
)

capital_campaign = GeneralAccountingUnit.create!(
  name: "Capital Campaign",
  description: "$368,000 infrastructure improvement project",
  active: true
)

puts "  ✅ Created #{GeneralAccountingUnit.count} GAUs (funds)"

# ============================================================
# 2. CREATE DONOR LEVELS
# ============================================================
DonorLevel.create!([
  { name: "Bronze",   minimum_amount: 100,   maximum_amount: 999,   sort_order: 1 },
  { name: "Silver",   minimum_amount: 1000,  maximum_amount: 4999,  sort_order: 2 },
  { name: "Gold",     minimum_amount: 5000,  maximum_amount: 9999,  sort_order: 3 },
  { name: "Platinum", minimum_amount: 10000, maximum_amount: nil,   sort_order: 4 },
])

puts "  ✅ Created #{DonorLevel.count} donor levels"

# ============================================================
# 3. CREATE A CAMPAIGN
# ============================================================
spring_appeal = Campaign.create!(
  name: "Spring 2025 Meals Appeal",
  campaign_type: :direct_mail,
  status: :in_progress,
  start_date: Date.new(2025, 3, 1),
  end_date: Date.new(2025, 5, 31),
  budgeted_cost: 2500,
  active: true,
  description: "Direct mail campaign targeting donors in the Panhandle region"
)

puts "  ✅ Created campaign: #{spring_appeal.name}"

# ============================================================
# 4. CREATE CONTACTS (auto-creates Household Accounts!)
#    Notice: we don't manually create the Account — the Contact
#    model's before_validation callback does it automatically.
# ============================================================
john = Contact.create!(
  first_name: "John",
  last_name: "Smith",
  salutation: "Mr.",
  personal_email: "john.smith@email.com",
  preferred_email: :personal,
  mobile_phone: "806-555-1234",
  preferred_phone: :mobile,
  lead_source: "Direct Mail"
)

# Jane goes into the SAME household as John
jane = Contact.create!(
  first_name: "Jane",
  last_name: "Smith",
  salutation: "Mrs.",
  personal_email: "jane.smith@email.com",
  preferred_email: :personal,
  mobile_phone: "806-555-5678",
  preferred_phone: :mobile,
  account: john.account   # <-- same Household Account!
)

bob = Contact.create!(
  first_name: "Bob",
  last_name: "Johnson",
  salutation: "Mr.",
  work_email: "bjohnson@acmecorp.com",
  preferred_email: :work,
  work_phone: "806-555-9999",
  preferred_phone: :work,
  lead_source: "Event"
)

puts "  ✅ Created #{Contact.count} contacts in #{Account.household.count} households"

# ============================================================
# 5. CREATE A RELATIONSHIP (John ↔ Jane are married)
#    The reciprocal is auto-created!
# ============================================================
Relationship.create!(
  contact: john,
  related_contact: jane,
  relationship_type: "Spouse",
  status: :current
)

puts "  ✅ Created relationship: John ↔ Jane (Spouse) — reciprocal auto-created!"
puts "     John's relationships: #{john.relationships.count}"
puts "     Jane's relationships: #{jane.relationships.count}"

# ============================================================
# 6. CREATE AN ADDRESS FOR THE SMITH HOUSEHOLD
# ============================================================
Address.create!(
  account: john.account,
  street: "123 Main Street",
  city: "Amarillo",
  state: "TX",
  postal_code: "79101",
  country: "US",
  address_type: :home,
  default_address: true
)

puts "  ✅ Created address for #{john.account.name}"
puts "     Contact mailing: #{john.reload.mailing_city}, #{john.mailing_state}"

# ============================================================
# 7. CREATE AN ORGANIZATION + AFFILIATION
#    Bob works at Acme Corp (an Organization Account)
# ============================================================
acme = Account.create!(
  name: "Acme Corporation",
  account_type: :organization,
  industry: "Manufacturing",
  phone: "806-555-0000",
  website: "https://acmecorp.example.com"
)

Affiliation.create!(
  contact: bob,
  organization: acme,
  role: "Employee",
  status: :current,
  primary: true,
  start_date: Date.new(2020, 6, 1)
)

puts "  ✅ Created organization: #{acme.name}"
puts "     Bob's primary affiliation: #{bob.reload.primary_affiliation&.name}"

# ============================================================
# 8. CREATE DONATIONS
# ============================================================

# John gives $500 — split across two funds
donation1 = Donation.create!(
  contact: john,
  amount: 500,
  close_date: Date.new(2025, 1, 15),
  stage: :received,
  gift_type: :check,
  campaign: spring_appeal,
  acknowledgment_status: :to_be_acknowledged
)

# Split: $300 to Meals, $200 to General Fund
GauAllocation.create!(donation: donation1, general_accounting_unit: meals_program, amount: 300)
GauAllocation.create!(donation: donation1, general_accounting_unit: general_fund, amount: 200)

# Bob gives $5,000 to the Capital Campaign (major gift!)
donation2 = Donation.create!(
  contact: bob,
  amount: 5000,
  close_date: Date.new(2025, 2, 1),
  stage: :received,
  gift_type: :credit_card,
  record_type: "Major Gift",
  acknowledgment_status: :to_be_acknowledged
)

GauAllocation.create!(donation: donation2, general_accounting_unit: capital_campaign, amount: 5000)

# Jane gives a tribute gift in memory of someone
donation3 = Donation.create!(
  contact: jane,
  amount: 100,
  close_date: Date.new(2025, 2, 3),
  stage: :received,
  gift_type: :credit_card,
  tribute_type: :in_memory_of,
  honoree_name: "Mary Williams"
)

GauAllocation.create!(donation: donation3, general_accounting_unit: meals_program, amount: 100)

puts "  ✅ Created #{Donation.count} donations totaling $#{Donation.sum(:amount)}"

# ============================================================
# 9. CREATE A RECURRING DONATION (monthly sustainer)
#    John commits to $50/month
# ============================================================
recurring = RecurringDonation.create!(
  contact: john,
  amount: 50,
  recurring_type: :open_ended,
  installment_period: :monthly,
  day_of_month: 15,
  start_date: Date.new(2025, 3, 15),
  status: :active,
  payment_method: :credit_card
)

puts "  ✅ Created recurring donation: #{recurring.donor_name} — $#{recurring.amount}/month"
puts "     First installment auto-created: #{recurring.donations.count} donation(s)"

# ============================================================
# 10. ADD JOHN TO THE CAMPAIGN
# ============================================================
CampaignMembership.create!(
  campaign: spring_appeal,
  contact: john,
  status: :responded
)

puts "  ✅ Added #{spring_appeal.contacts.count} member(s) to #{spring_appeal.name}"

# ============================================================
# 11. CREATE A STEWARDSHIP PLAN
# ============================================================
major_donor_plan = EngagementPlanTemplate.create!(
  name: "Major Donor Stewardship",
  description: "Follow-up sequence for gifts of $1,000+",
  skip_weekends: true
)

EngagementPlanTask.create!([
  { engagement_plan_template: major_donor_plan, subject: "Thank-you phone call",    days_after: 1,  task_type: "Call",   priority: :high },
  { engagement_plan_template: major_donor_plan, subject: "Handwritten thank-you note", days_after: 3, task_type: "Letter", priority: :normal },
  { engagement_plan_template: major_donor_plan, subject: "Send impact report",       days_after: 30, task_type: "Email",  priority: :normal },
  { engagement_plan_template: major_donor_plan, subject: "Personal check-in call",   days_after: 90, task_type: "Call",   priority: :normal },
])

# Apply the plan to Bob's major gift
major_donor_plan.apply_to(bob)

puts "  ✅ Applied '#{major_donor_plan.name}' to #{bob.full_name}"
puts "     Created #{Task.count} tasks"

# ============================================================
# SUMMARY
# ============================================================
puts ""
puts "=" * 60
puts "🎉 Seed complete!"
puts "=" * 60
puts "  Accounts:            #{Account.count} (#{Account.household.count} households, #{Account.organization.count} orgs)"
puts "  Contacts:            #{Contact.count}"
puts "  Donations:           #{Donation.count}"
puts "  Recurring Donations: #{RecurringDonation.count}"
puts "  Payments:            #{Payment.count}"
puts "  GAUs (Funds):        #{GeneralAccountingUnit.count}"
puts "  GAU Allocations:     #{GauAllocation.count}"
puts "  Campaigns:           #{Campaign.count}"
puts "  Relationships:       #{Relationship.count}"
puts "  Affiliations:        #{Affiliation.count}"
puts "  Addresses:           #{Address.count}"
puts "  Tasks:               #{Task.count}"
puts "  Donor Levels:        #{DonorLevel.count}"
puts ""
puts "  John's rollups:"
john.reload
puts "    Total Gifts:     $#{john.total_gifts}"
puts "    Number of Gifts: #{john.number_of_gifts}"
puts "    First Gift Date: #{john.first_gift_date}"
puts ""
puts "  Meals Program fund:"
meals_program.reload
puts "    Total Allocated: $#{meals_program.total_allocations}"
