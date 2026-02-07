# app/models/campaign.rb
#
# Tracks fundraising campaigns, events, appeals, and marketing initiatives.
#
class Campaign < ApplicationRecord
  enum :campaign_type, { email: 0, direct_mail: 1, event: 2, webinar: 3, advertisement: 4, other_campaign: 5 }
  enum :status, { planned: 0, in_progress: 1, completed: 2, aborted: 3 }

  # Hierarchy
  belongs_to :parent_campaign, class_name: "Campaign", optional: true
  has_many   :child_campaigns, class_name: "Campaign", foreign_key: :parent_campaign_id

  # Members (Contacts who participated)
  has_many :campaign_memberships, dependent: :destroy
  has_many :contacts, through: :campaign_memberships

  # Donations sourced from this campaign
  has_many :donations

  # Fund allocations (default GAU for this campaign's donations)
  has_many :gau_allocations, dependent: :destroy

  # Recurring donations tied to this campaign
  has_many :recurring_donations

  validates :name, presence: true

  scope :active_campaigns, -> { where(active: true) }

  # ROI calculation
  def return_on_investment
    return 0 if budgeted_cost.blank? || budgeted_cost.zero?

    total_raised = donations.where(is_won: true).sum(:amount) || 0
    ((total_raised - budgeted_cost) / budgeted_cost * 100).round(1)
  end
end
