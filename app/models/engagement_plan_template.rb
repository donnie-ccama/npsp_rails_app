# app/models/engagement_plan_template.rb
#
# A reusable stewardship blueprint defining a sequence of tasks.
# Example: "New Major Donor" plan → Day 1 thank-you call, Day 3 note, Day 30 impact report
#
class EngagementPlanTemplate < ApplicationRecord
  has_many :engagement_plan_tasks, dependent: :destroy
  has_many :engagement_plans, dependent: :nullify

  validates :name, presence: true

  # Apply this template to a record, creating an active plan with tasks
  def apply_to(record)
    plan = engagement_plans.create!(
      plannable: record,
      status: :active,
      start_date: Date.current
    )

    engagement_plan_tasks.order(:days_after).each do |template_task|
      due_date = plan.start_date + template_task.days_after.days
      due_date = due_date.next_weekday if skip_weekends? && due_date.on_weekend?

      task_attrs = {
        subject: template_task.subject,
        task_type: template_task.task_type,
        priority: template_task.priority.nil? ? :normal : template_task.priority,
        due_date: due_date,
        taskable: record,
        description: template_task.comments,
        assigned_to: template_task.assigned_to_type
      }
      task_attrs[:contact] = record if record.is_a?(Contact)
      Task.create!(task_attrs)
    end

    plan
  end
end
