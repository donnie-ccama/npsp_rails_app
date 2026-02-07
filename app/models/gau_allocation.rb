# app/models/gau_allocation.rb
#
# Junction object that links a GAU (fund) to a Donation, Recurring Donation,
# or Campaign. Allows splitting a single gift across multiple funds.
#
# Example: A $1,000 donation split 60% to General Fund, 40% to Meals Program.
#
class GauAllocation < ApplicationRecord
  belongs_to :general_accounting_unit
  belongs_to :donation,           optional: true
  belongs_to :recurring_donation, optional: true
  belongs_to :campaign,           optional: true

  validates :general_accounting_unit, presence: true
  validate  :at_least_one_parent
  validate  :amount_or_percent_present

  after_save    :update_gau_rollups
  after_destroy :update_gau_rollups

  private

  def at_least_one_parent
    if donation.blank? && recurring_donation.blank? && campaign.blank?
      errors.add(:base, "Must be allocated to a Donation, Recurring Donation, or Campaign")
    end
  end

  def amount_or_percent_present
    if amount.blank? && percent.blank?
      errors.add(:base, "Either amount or percent must be specified")
    end
  end

  def update_gau_rollups
    general_accounting_unit&.recalculate_rollups!
  end
end
