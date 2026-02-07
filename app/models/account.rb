# app/models/account.rb
#
# The Account model represents either a Household (family of donors)
# or an Organization (company, foundation, school).
#
# In NPSP, this is the central hub — most other records connect here.
#
class Account < ApplicationRecord
  # ---------------------------------------------------------------
  # ENUMS — these create helper methods automatically!
  #   account.household?  => true/false
  #   Account.household   => returns all households
  # ---------------------------------------------------------------
  enum :account_type, { household: 0, organization: 1 }

  # ---------------------------------------------------------------
  # ASSOCIATIONS — how this model connects to others
  # ---------------------------------------------------------------
  # A Household has many family members (Contacts)
  has_many :contacts, dependent: :nullify

  # A Household/Org has many Donations (through its members or directly)
  has_many :donations, dependent: :nullify

  # NPSP Address management — multiple addresses per Household
  has_many :addresses, dependent: :destroy

  # Organizational affiliations (people connected to this org)
  has_many :affiliations, foreign_key: :organization_id, dependent: :destroy

  # Recurring Donations from this account (org-level donors)
  has_many :recurring_donations, dependent: :nullify

  # Soft credits attributed to this organization
  has_many :account_soft_credits, dependent: :destroy

  # Account hierarchy (parent/child orgs like corporate subsidiaries)
  belongs_to :parent_account, class_name: "Account", optional: true
  has_many   :child_accounts, class_name: "Account", foreign_key: :parent_account_id

  # ---------------------------------------------------------------
  # VALIDATIONS — rules that must be true before saving
  # ---------------------------------------------------------------
  validates :name, presence: true
  validates :account_type, presence: true

  # ---------------------------------------------------------------
  # SCOPES — reusable query shortcuts
  #   Account.households  => all household accounts
  #   Account.with_gifts  => accounts that have donated
  # ---------------------------------------------------------------
  scope :households,    -> { where(account_type: :household) }
  scope :organizations, -> { where(account_type: :organization) }
  scope :with_gifts,    -> { where("number_of_gifts > 0") }

  # ---------------------------------------------------------------
  # NPSP-STYLE METHODS
  # ---------------------------------------------------------------

  # Auto-generate household name from member contacts
  # e.g., "Smith Household" or "Smith & Jones Household"
  def generate_household_name
    return unless household?

    last_names = contacts.pluck(:last_name).uniq
    self.name = if last_names.length == 1
                  "#{last_names.first} Household"
                else
                  "#{last_names.join(' & ')} Household"
                end
  end

  # Auto-generate greetings from member contacts
  def generate_greetings
    return unless household?

    members = contacts.where(deceased: false).order(:created_at)
    self.formal_greeting = members.map { |c|
      [c.salutation, c.first_name, c.last_name].compact.join(" ")
    }.join(" and ")
    self.informal_greeting = members.map(&:first_name).join(" and ")
  end

  # Recalculate all donation rollup fields
  # Call this after a donation is created, updated, or deleted
  def recalculate_rollups!
    won_donations = donations.where(is_won: true)

    self.total_gifts           = won_donations.sum(:amount) || 0
    self.number_of_gifts       = won_donations.count
    self.average_gift          = number_of_gifts > 0 ? total_gifts / number_of_gifts : 0
    self.largest_gift          = won_donations.maximum(:amount)
    self.smallest_gift         = won_donations.minimum(:amount)
    self.first_gift_date       = won_donations.minimum(:close_date)
    self.last_gift_date        = won_donations.maximum(:close_date)
    self.last_gift_amount      = won_donations.order(close_date: :desc).first&.amount
    self.total_gifts_this_year = won_donations.where(close_date: Time.current.beginning_of_year..Time.current.end_of_year).sum(:amount) || 0
    self.total_gifts_last_year = won_donations.where(close_date: 1.year.ago.beginning_of_year..1.year.ago.end_of_year).sum(:amount) || 0

    save!
  end

  # Default address (for mailings)
  def default_address
    addresses.find_by(default_address: true)
  end
end
