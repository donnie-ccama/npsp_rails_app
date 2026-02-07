# app/models/recurring_donation.rb
#
# Tracks ongoing gift commitments — monthly sustainers, annual pledges, etc.
# Auto-creates child Donation (installment) records on a schedule.
#
class RecurringDonation < ApplicationRecord
  # ---------------------------------------------------------------
  # ENUMS
  # ---------------------------------------------------------------
  enum :recurring_type,     { open_ended: 0, fixed: 1 }
  enum :installment_period, { monthly: 0, quarterly: 1, yearly: 2, weekly: 3, bimonthly: 4 }
  enum :status,             { active: 0, lapsed: 1, closed: 2, paused: 3 }
  enum :payment_method,     { credit_card: 0, check: 1, ach: 2, rd_cash: 3 }, prefix: true

  # ---------------------------------------------------------------
  # ASSOCIATIONS
  # ---------------------------------------------------------------
  belongs_to :contact,  optional: true   # individual donor
  belongs_to :account,  optional: true   # organizational donor
  belongs_to :campaign, optional: true

  # Child installment Donations auto-created by the schedule
  has_many :donations, dependent: :nullify

  # Fund allocations (cascade to child Donations)
  has_many :gau_allocations, dependent: :destroy

  # ---------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :recurring_type, presence: true
  validates :installment_period, presence: true
  validates :start_date, presence: true
  validates :status, presence: true

  # At least one donor is required
  validate :donor_present

  # ---------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------
  before_validation :auto_generate_name, on: :create
  before_save :calculate_next_donation_date
  after_create :create_first_installment

  # ---------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------
  scope :active_recurring, -> { where(status: :active) }
  scope :due_today,        -> { active_recurring.where("next_donation_date <= ?", Date.current) }

  # ---------------------------------------------------------------
  # METHODS
  # ---------------------------------------------------------------

  # The donor (either individual or organization)
  def donor_name
    contact&.full_name || account&.name || "Unknown"
  end

  # Create the next installment Donation
  def create_installment!
    return unless active?

    # First installment uses start_date; subsequent use next_donation_date
    close_date = donations.empty? ? start_date : (next_donation_date || Date.current)

    donation = donations.create!(
      contact: contact,
      account: contact&.account || account,
      amount: amount,
      close_date: close_date,
      stage: :pledged,
      campaign: campaign,
      record_type: "Recurring Donation"
    )

    # Copy GAU allocations to the new Donation
    gau_allocations.each do |alloc|
      donation.gau_allocations.create!(
        general_accounting_unit: alloc.general_accounting_unit,
        amount: alloc.amount,
        percent: alloc.percent
      )
    end

    calculate_next_donation_date(close_date)
    save!
    donation
  end

  private

  def donor_present
    if contact.blank? && account.blank?
      errors.add(:base, "Either a Contact or Account donor is required")
    end
  end

  def auto_generate_name
    return if name.present?

    self.name = "RD-#{SecureRandom.hex(3).upcase}"
  end

  def calculate_next_donation_date(from_date = nil)
    base = from_date || next_donation_date || start_date || Date.current

    self.next_donation_date = case installment_period
                              when "monthly"   then base + 1.month
                              when "quarterly" then base + 3.months
                              when "yearly"    then base + 1.year
                              when "weekly"    then base + 1.week
                              when "bimonthly" then base + 2.months
                              else base + 1.month
                              end
  end

  def create_first_installment
    create_installment! if active?
  end
end
