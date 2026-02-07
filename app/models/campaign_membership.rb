# app/models/campaign_membership.rb
#
# Junction: links a Contact to a Campaign with status tracking.
#
class CampaignMembership < ApplicationRecord
  enum :status, { sent: 0, responded: 1, attended: 2, no_show: 3 }

  belongs_to :campaign
  belongs_to :contact

  validates :campaign, presence: true
  validates :contact, presence: true
  validates :contact_id, uniqueness: { scope: :campaign_id, message: "is already a member of this campaign" }
end
