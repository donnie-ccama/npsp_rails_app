# app/models/general_accounting_unit.rb
#
# Represents a fund, program, or designation.
# Examples: "General Fund", "Meals Program", "Capital Campaign"
#
# Donations are linked to GAUs through GauAllocation records,
# which allows splitting a single gift across multiple funds.
#
class GeneralAccountingUnit < ApplicationRecord
  has_many :gau_allocations, dependent: :destroy
  has_many :donations, through: :gau_allocations

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  # Recalculate rollup fields from allocations
  def recalculate_rollups!
    allocs = gau_allocations
               .joins(:donation)
               .where(donations: { is_won: true })

    self.total_allocations           = allocs.sum(:amount) || 0
    self.total_number_of_allocations = allocs.count
    self.largest_allocation          = allocs.maximum(:amount)
    self.smallest_allocation         = allocs.minimum(:amount)
    self.average_allocation          = total_number_of_allocations > 0 ? total_allocations / total_number_of_allocations : 0
    self.first_allocation_date       = allocs.joins(:donation).minimum("donations.close_date")
    self.last_allocation_date        = allocs.joins(:donation).maximum("donations.close_date")

    save!
  end
end
