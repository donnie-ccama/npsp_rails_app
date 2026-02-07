# app/models/payment.rb
#
# Tracks individual payment installments against a Donation.
# One Donation can have many Payments (e.g., a pledge paid in 4 checks).
#
# Master-Detail: deleting the Donation deletes all its Payments.
#
class Payment < ApplicationRecord
  enum :payment_method, { cash: 0, check: 1, credit_card: 2, ach: 3, wire: 4, stock: 5 }, prefix: true

  # ---------------------------------------------------------------
  # ASSOCIATIONS
  # ---------------------------------------------------------------
  belongs_to :donation  # master-detail (required, cascade delete via Donation model)

  # ---------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------
  validates :amount, numericality: { greater_than: 0 }, allow_nil: true

  # ---------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------
  after_save    :update_donation_status
  after_destroy :update_donation_status

  # ---------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------
  scope :paid,       -> { where(paid: true) }
  scope :unpaid,     -> { where(paid: false) }
  scope :overdue,    -> { unpaid.where("scheduled_date < ?", Date.current) }

  private

  # If all payments are paid, mark the Donation as received
  def update_donation_status
    return unless donation

    all_paid = donation.payments.all? { |p| p.paid? }
    if all_paid && donation.payments.any?
      donation.update(stage: :received) unless donation.received? || donation.thanked?
    end
  end
end
