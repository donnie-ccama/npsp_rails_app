class CreatePartialSoftCredits < ActiveRecord::Migration[7.1]
  def change
    create_table :partial_soft_credits do |t|
      t.references :contact,  null: false, foreign_key: true
      t.references :donation, null: false, foreign_key: true

      t.decimal    :amount,   precision: 15, scale: 2   # partial credit amount
      t.string     :role                                 # Soft Credit, Influencer, Solicitor

      t.timestamps
    end
  end
end
