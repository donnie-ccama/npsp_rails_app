# app/models/engagement_plan_task.rb
#
# A single step within an Engagement Plan Template.
# Defines what task to create, when, and for whom.
#
class EngagementPlanTask < ApplicationRecord
  enum :priority, { high: 0, normal: 1, low: 2 }

  belongs_to :engagement_plan_template

  validates :subject, presence: true
  validates :days_after, numericality: { greater_than_or_equal_to: 0 }
end
