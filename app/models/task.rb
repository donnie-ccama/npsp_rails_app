# app/models/task.rb
#
# A to-do item: thank-you call, follow-up email, stewardship action, etc.
#
# Polymorphic: can be attached to any record type (Contact, Donation, Account, etc.)
# This is how Rails handles Salesforce's "WhatId" polymorphic lookup.
#
class Task < ApplicationRecord
  enum :status,   { not_started: 0, in_progress: 1, task_completed: 2, waiting: 3, deferred: 4 }
  enum :priority, { high: 0, normal: 1, low: 2 }

  # Polymorphic association — "taskable" can be any model
  belongs_to :taskable, polymorphic: true, optional: true

  # Optional direct link to the person involved
  belongs_to :contact, optional: true

  before_save :set_closed_flag

  scope :open_tasks,    -> { where(is_closed: false) }
  scope :overdue,       -> { open_tasks.where("due_date < ?", Date.current) }
  scope :due_today,     -> { open_tasks.where(due_date: Date.current) }
  scope :upcoming_week, -> { open_tasks.where(due_date: Date.current..7.days.from_now) }

  private

  def set_closed_flag
    self.is_closed = status == "task_completed"
  end
end
