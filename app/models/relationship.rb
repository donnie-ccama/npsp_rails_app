# app/models/relationship.rb
#
# Tracks personal relationships between two Contacts.
# Auto-creates a reciprocal record (if A is spouse of B, B is spouse of A).
#
class Relationship < ApplicationRecord
  enum :status, { current: 0, former: 1 }

  belongs_to :contact
  belongs_to :related_contact, class_name: "Contact"
  belongs_to :reciprocal_relationship, class_name: "Relationship", optional: true

  validates :contact, presence: true
  validates :related_contact, presence: true
  validates :relationship_type, presence: true

  after_create  :create_reciprocal, unless: :reciprocal_relationship_id?
  after_destroy :destroy_reciprocal

  # ---------------------------------------------------------------
  # RECIPROCAL TYPE MAPPING
  # If A→B is "Parent", B→A should be "Child"
  # ---------------------------------------------------------------
  RECIPROCAL_TYPES = {
    "Spouse"    => "Spouse",
    "Partner"   => "Partner",
    "Parent"    => "Child",
    "Child"     => "Parent",
    "Sibling"   => "Sibling",
    "Friend"    => "Friend",
    "Colleague" => "Colleague",
    "Employer"  => "Employee",
    "Employee"  => "Employer",
    "Mentor"    => "Mentee",
    "Mentee"    => "Mentor"
  }.freeze

  private

  def create_reciprocal
    reciprocal = Relationship.create!(
      contact: related_contact,
      related_contact: contact,
      relationship_type: RECIPROCAL_TYPES[relationship_type] || relationship_type,
      status: status,
      reciprocal_relationship: self
    )
    update_column(:reciprocal_relationship_id, reciprocal.id)
  end

  def destroy_reciprocal
    reciprocal_relationship&.destroy if reciprocal_relationship&.persisted?
  end
end
