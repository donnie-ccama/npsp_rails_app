# app/models/donor_level.rb
#
# Defines donor tiers (Bronze, Silver, Gold, Platinum) based on giving thresholds.
# Auto-assigns levels to Contacts based on their rollup values.
#
# Example:
#   Bronze:   $100 – $999
#   Silver:   $1,000 – $4,999
#   Gold:     $5,000 – $9,999
#   Platinum: $10,000+
#
class DonorLevel < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :minimum_amount, presence: true

  scope :ordered, -> { order(sort_order: :asc) }

  # Find the appropriate level for a given amount
  def self.level_for(amount)
    ordered.where("minimum_amount <= ?", amount)
           .where("maximum_amount IS NULL OR maximum_amount >= ?", amount)
           .last
  end

  # Recalculate donor levels for all contacts
  # Run this as a periodic job (e.g., nightly via Sidekiq/cron)
  def self.recalculate_all!
    Contact.donors.find_each do |contact|
      level = level_for(contact.total_gifts || 0)
      contact.update_column(:donor_level, level&.name)
    end
  end
end
