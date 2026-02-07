# app/models/engagement_plan.rb
#
# An active instance of a stewardship plan applied to a specific record.
#
class EngagementPlan < ApplicationRecord
  enum :status, { active: 0, ep_completed: 1, cancelled: 2 }

  belongs_to :engagement_plan_template
  belongs_to :plannable, polymorphic: true

  validates :start_date, presence: true
end
