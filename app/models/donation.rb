# app/models/donation.rb
#
# The Donation model replaces Salesforce's "Opportunity" object.
# It represents a gift, grant, pledge, in-kind contribution, or membership payment.
#
# This is the financial heart of the CRM.
#
class Donation < ApplicationRecord
  # ---------------------------------------------------------------
  # ENUMS
  # ---------------------------------------------------------------
  enum :stage, {
    pledged: 0,        # promised but not yet received
    posted: 1,         # in process (check in mail, etc.)
    received: 2,       # closed/won — money is in hand
    closed_lost: 3,    # fell through
    thanked: 4         # received AND acknowledged
  }

  enum :gift_type, {
    cash: 0, check: 1, credit_card: 2, wire: 3,
    stock: 4, in_kind: 5, crypto: 6
  }, prefix: true

  enum :acknowledgment_status, {
    to_be_acknowledged: 0, acknowledged: 1,
    do_not_acknowledge: 2, email_sent: 3
  }, prefix: true

  enum :tribute_type, { in_honor_of: 0, in_memory_of: 1 }, prefix: true

  enum :matching_gift_status, {
    potential: 0, submitted: 1, match_received: 2, not_applicable: 3
  }, prefix: true

  # ---------------------------------------------------------------
  # ASSOCIATIONS
  # ---------------------------------------------------------------
  belongs_to :account,            optional: true      # Household Account
  belongs_to :contact,            optional: true      # Primary donor
  belongs_to :campaign,           optional: true      # Source campaign
  belongs_to :recurring_donation, optional: true      # Parent if installment

  # Tribute lookups
  belongs_to :honoree_contact,        class_name: "Contact", optional: true
  belongs_to :notification_recipient, class_name: "Contact", optional: true

  # Matching gift lookups
  belongs_to :matching_gift_account,  class_name: "Account", optional: true
  belongs_to :matching_gift_donation, class_name: "Donation", optional: true

  # Master-Detail: deleting a Donation deletes its Payments
  has_many :payments, dependent: :destroy

  # Fund allocation (split across multiple GAUs)
  has_many :gau_allocations, dependent: :destroy
  has_many :general_accounting_units, through: :gau_allocations

  # Contact roles (who did what on this gift)
  has_many :donation_contact_roles, dependent: :destroy

  # Soft credits
  has_many :partial_soft_credits, dependent: :destroy
  has_many :account_soft_credits, dependent: :destroy

  # Tasks and activities related to this donation
  has_many :tasks, as: :taskable

  # ---------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------
  validates :close_date, presence: true
  validates :stage, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # ---------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------
  before_validation :auto_generate_name, on: :create
  before_save       :set_closed_flags
  before_save       :set_account_from_contact
  after_save        :create_primary_contact_role, if: :saved_change_to_contact_id?
  after_save        :update_rollups
  after_destroy     :update_rollups

  # ---------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------
  scope :won,         -> { where(is_won: true) }
  scope :open,        -> { where(is_closed: false) }
  scope :this_year,   -> { where(close_date: Time.current.beginning_of_year..Time.current.end_of_year) }
  scope :last_year,   -> { where(close_date: 1.year.ago.beginning_of_year..1.year.ago.end_of_year) }

  # ---------------------------------------------------------------
  # METHODS
  # ---------------------------------------------------------------

  # Expected revenue = amount × probability
  def expected_revenue
    return 0 unless amount && probability

    amount * (probability / 100.0)
  end

  # Total paid so far (from Payment records)
  def total_paid
    payments.where(paid: true).sum(:amount) || 0
  end

  # Remaining balance
  def balance_due
    (amount || 0) - total_paid
  end

  private

  # Auto-name like NPSP: "Smith Household 01/2025 Donation"
  def auto_generate_name
    return if name.present?

    account_name = account&.name || contact&.full_name || "Unknown"
    date_str     = close_date&.strftime("%m/%Y") || Date.current.strftime("%m/%Y")
    type_str     = record_type.presence || "Donation"
    self.name    = "#{account_name} #{date_str} #{type_str}"
  end

  # Set is_closed and is_won based on stage
  def set_closed_flags
    self.is_closed = stage.in?(%w[received closed_lost thanked])
    self.is_won    = stage.in?(%w[received thanked])
  end

  # Auto-set account from the contact's household
  def set_account_from_contact
    return if account.present? || contact.blank?

    self.account = contact.account
  end

  # Auto-create a "Donor" contact role for the primary contact
  def create_primary_contact_role
    return if contact.blank?

    donation_contact_roles.find_or_create_by!(
      contact: contact,
      role: "Donor",
      is_primary: true
    )
  end

  # After saving/deleting, recalculate rollups on parent records
  def update_rollups
    contact&.recalculate_rollups!
    account&.recalculate_rollups!
  end
end
