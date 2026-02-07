# app/models/donation_contact_role.rb
#
# Links a Contact to a Donation with a specific role.
# Replaces Salesforce's OpportunityContactRole.
#
# Examples:
#   John Smith → Donor (primary) on $5,000 gift
#   Jane Smith → Soft Credit on same gift (spousal influence)
#   Bob Jones  → Solicitor on same gift (asked for the donation)
#
class DonationContactRole < ApplicationRecord
  belongs_to :donation
  belongs_to :contact

  validates :role, presence: true
  validates :contact_id, uniqueness: { scope: [:donation_id, :role] }

  # Common roles
  ROLES = %w[Donor Soft\ Credit Solicitor Honoree Influencer Tribute\ Notification].freeze
end
