class CreateAccountSoftCredits < ActiveRecord::Migration[7.1]
  def change
    create_table :account_soft_credits do |t|
      t.references :account,  null: false, foreign_key: true
      t.references :donation, null: false, foreign_key: true

      t.decimal    :amount,   precision: 15, scale: 2
      t.string     :role                               # Matching Donor, Sponsor, etc.

      t.timestamps
    end
  end
end
