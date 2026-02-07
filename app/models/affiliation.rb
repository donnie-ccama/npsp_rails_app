# app/models/affiliation.rb
#
# Links a Contact to an Organization Account with a role.
# Unlike the single Account lookup, a Contact can have MANY affiliations.
#
# Examples:
#   Jane Smith → Employee at Acme Corp (current)
#   Jane Smith → Board Member at Community Foundation (current)
#   Jane Smith → Alumni at State University (former)
#
class Affiliation < ApplicationRecord
  enum :status, { current: 0, former: 1 }

  belongs_to :contact
  belongs_to :organization, class_name: "Account"

  validates :contact, presence: true
  validates :organization, presence: true

  # When marked as primary, update the contact's primary_affiliation
  after_save :sync_primary_affiliation, if: :primary?

  scope :current_affiliations, -> { where(status: :current) }
  scope :primary_affiliations, -> { where(primary: true) }

  private

  def sync_primary_affiliation
    contact.update(primary_affiliation: organization)
  end
end
