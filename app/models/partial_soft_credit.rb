# app/models/partial_soft_credit.rb
#
# Tracks partial attribution of a donation to a Contact
# other than the primary donor.
#
class PartialSoftCredit < ApplicationRecord
  belongs_to :contact
  belongs_to :donation

  validates :amount, numericality: { greater_than: 0 }, allow_nil: true

  after_save    :update_contact_soft_credit_rollups
  after_destroy :update_contact_soft_credit_rollups

  private

  def update_contact_soft_credit_rollups
    contact&.recalculate_rollups!
  end
end
