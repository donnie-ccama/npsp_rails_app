# app/models/address.rb
#
# Manages multiple addresses per Household Account.
# Supports seasonal addresses (e.g., winter home in Arizona).
#
class Address < ApplicationRecord
  enum :address_type, { home: 0, work: 1, other_addr: 2, seasonal: 3 }

  belongs_to :account

  validates :account, presence: true

  after_save :sync_to_account_and_contacts, if: :default_address?

  scope :default_addresses, -> { where(default_address: true) }
  scope :seasonal_addresses, -> { where(address_type: :seasonal) }

  # Check if a seasonal address is currently active
  def currently_active?
    return true unless seasonal?
    return false if seasonal_start_month.blank? || seasonal_end_month.blank?

    today = Date.current
    start_date = Date.new(today.year, seasonal_start_month, seasonal_start_day || 1)
    end_date   = Date.new(today.year, seasonal_end_month, seasonal_end_day || 28)

    today.between?(start_date, end_date)
  end

  def full_address
    [street, city, state, postal_code, country].compact.reject(&:blank?).join(", ")
  end

  private

  # When this is the default address, push it to Account and Contact mailing fields
  def sync_to_account_and_contacts
    account.update(
      billing_street: street,
      billing_city: city,
      billing_state: state,
      billing_postal_code: postal_code,
      billing_country: country
    )

    account.contacts.each do |contact|
      contact.update(
        mailing_street: street,
        mailing_city: city,
        mailing_state: state,
        mailing_postal_code: postal_code,
        mailing_country: country
      )
    end
  end
end
