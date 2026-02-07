class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string     :subject                            # "Thank you call", "Send impact report"
      t.text       :description
      t.date       :due_date
      t.integer    :status,      default: 0            # enum: not_started, in_progress, completed, waiting, deferred
      t.integer    :priority,    default: 1            # enum: high, normal, low
      t.string     :task_type                          # Call, Email, Letter, Meeting, Other

      # --- Polymorphic: what record is this task about? ---
      t.string     :taskable_type                      # "Contact", "Account", "Donation", etc.
      t.bigint     :taskable_id

      # --- Who is the person involved? (Contact) ---
      t.references :contact, foreign_key: true, null: true

      # --- Who is assigned to do this? ---
      # (In a real app, this would reference a User model)
      t.string     :assigned_to

      t.boolean    :is_closed,   default: false

      t.timestamps
    end

    add_index :tasks, [:taskable_type, :taskable_id]
    add_index :tasks, :status
    add_index :tasks, :due_date
  end
end
