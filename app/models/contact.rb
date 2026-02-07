# app/models/contact.rb
#
# The Contact model represents any individual person:
# donors, volunteers, board members, clients, advocates.
#
# This is the most-used model in a nonprofit CRM.
#
class Contact < ApplicationRecord
  # ---------------------------------------------------------------
  # ENUMS
  # ---------------------------------------------------------------
  enum :preferred_email, { personal: 0, work: 1, alternate: 2 }, prefix: true
  enum :preferred_phone, { home: 0, work: 1, mobile: 2, other: 3 }, prefix: true

  # ---------------------------------------------------------------
  # ASSOCIATIONS
  # ---------------------------------------------------------------
  # Every Contact belongs to a Household Account
  belongs_to :account, optional: true

  # Primary organizational affiliation (employer, etc.)
  belongs_to :primary_affiliation, class_name: "Account", optional: true

  # Donations where this person is the primary donor
  has_many :donations, dependent: :nullify

  # Recurring giving commitments
  has_many :recurring_donations, dependent: :nullify

  # Payments (through their donations)
  has_many :payments, through: :donations

  # Roles on donations (Donor, Soft Credit, Solicitor, etc.)
  has_many :donation_contact_roles, dependent: :destroy

  # Soft credits (partial attribution from other people's gifts)
  has_many :partial_soft_credits, dependent: :destroy

  # Organizational connections (employer, board, school)
  has_many :affiliations, dependent: :destroy
  has_many :affiliated_organizations, through: :affiliations,
           source: :organization

  # Personal relationships (spouse, parent, friend)
  has_many :relationships, dependent: :destroy
  has_many :related_contacts, through: :relationships

  # Campaign participation
  has_many :campaign_memberships, dependent: :destroy
  has_many :campaigns, through: :campaign_memberships

  # Tasks assigned or related to this person
  has_many :tasks

  # ---------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------
  validates :last_name, presence: true

  # ---------------------------------------------------------------
  # CALLBACKS — automatic actions on save/create
  # ---------------------------------------------------------------

  # Auto-create a Household Account if none exists
  before_validation :ensure_household_account, on: :create

  # Sync the preferred email to the main email field
  before_save :sync_preferred_email
  before_save :sync_preferred_phone

  # ---------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------
  scope :active,    -> { where(deceased: false, do_not_contact: false) }
  scope :donors,    -> { where("number_of_gifts > 0") }
  scope :lapsed,    -> { donors.where("last_gift_date < ?", 18.months.ago) }
  scope :new_donors, -> { donors.where("first_gift_date > ?", 1.year.ago) }

  # ---------------------------------------------------------------
  # HELPER METHODS
  # ---------------------------------------------------------------

  def full_name
    [first_name, last_name].compact.join(" ")
  end

  def formal_name
    [salutation, first_name, last_name].compact.join(" ")
  end

  # LYBUNT = "Last Year But Unfortunately Not This" year
  def lybunt?
    return false if total_gifts_last_year.nil? || total_gifts_last_year.zero?

    total_gifts_this_year.nil? || total_gifts_this_year.zero?
  end

  # SYBUNT = "Some Year But Unfortunately Not This" year
  def sybunt?
    number_of_gifts.to_i > 0 && (total_gifts_this_year.nil? || total_gifts_this_year.zero?)
  end

  # Recalculate all donation rollup fields
  def recalculate_rollups!
    won_donations = donations.where(is_won: true)

    self.total_gifts              = won_donations.sum(:amount) || 0
    self.number_of_gifts          = won_donations.count
    self.average_gift             = number_of_gifts > 0 ? total_gifts / number_of_gifts : 0
    self.largest_gift             = won_donations.maximum(:amount)
    self.smallest_gift            = won_donations.minimum(:amount)
    self.first_gift_date          = won_donations.minimum(:close_date)
    self.last_gift_date           = won_donations.maximum(:close_date)
    self.last_gift_amount         = won_donations.order(close_date: :desc).first&.amount
    self.total_gifts_this_year    = won_donations.where(close_date: Time.current.beginning_of_year..Time.current.end_of_year).sum(:amount) || 0
    self.total_gifts_last_year    = won_donations.where(close_date: 1.year.ago.beginning_of_year..1.year.ago.end_of_year).sum(:amount) || 0

    # Soft credit rollups
    self.total_soft_credits       = partial_soft_credits.sum(:amount) || 0
    self.number_of_soft_credits   = partial_soft_credits.count

    save!
  end

  private

  # NPSP auto-creates a Household Account when a Contact is created
  def ensure_household_account
    return if account.present?

    self.account = Account.create!(
      name: "#{last_name} Household",
      account_type: :household
    )
  end

  # Copy the preferred email address into the main email field
  def sync_preferred_email
    self.email = case preferred_email
                 when "personal" then personal_email
                 when "work"     then work_email
                 when "alternate" then alternate_email
                 else personal_email || work_email || alternate_email
                 end
  end

  def sync_preferred_phone
    self.phone = case preferred_phone
                 when "home"   then home_phone
                 when "work"   then work_phone
                 when "mobile" then mobile_phone
                 when "other"  then other_phone
                 else home_phone || mobile_phone || work_phone
                 end
  end
end
