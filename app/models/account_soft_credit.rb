# app/models/account_soft_credit.rb
#
# Tracks soft credit attribution to an organizational Account.
#
class AccountSoftCredit < ApplicationRecord
  belongs_to :account
  belongs_to :donation

  validates :amount, numericality: { greater_than: 0 }, allow_nil: true
end
