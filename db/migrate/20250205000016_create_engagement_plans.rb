class CreateEngagementPlans < ActiveRecord::Migration[7.1]
  def change
    # --- Reusable stewardship blueprint ---
    create_table :engagement_plan_templates do |t|
      t.string     :name,        null: false           # "New Major Donor Stewardship"
      t.text       :description
      t.boolean    :skip_weekends,  default: true      # push tasks to Monday if they land on a weekend
      t.boolean    :reschedule_to,  default: false     # reschedule missed tasks to today

      t.timestamps
    end

    # --- Individual steps within a template ---
    create_table :engagement_plan_tasks do |t|
      t.references :engagement_plan_template, null: false, foreign_key: true

      t.string     :subject,       null: false         # "Thank you phone call"
      t.integer    :days_after,    default: 0          # days after plan creation
      t.string     :assigned_to_type                   # "owner" or specific user
      t.integer    :priority,      default: 0          # enum: high, normal, low
      t.string     :task_type                          # Call, Email, Letter, Meeting, Other
      t.text       :comments

      t.timestamps
    end

    # --- An active instance of a plan applied to a specific record ---
    create_table :engagement_plans do |t|
      t.references :engagement_plan_template, null: false, foreign_key: true

      # Polymorphic: can be applied to Contact, Account, Donation, etc.
      t.string     :plannable_type
      t.bigint     :plannable_id

      t.integer    :status,       default: 0           # enum: active, completed, cancelled
      t.date       :start_date

      t.timestamps
    end

    add_index :engagement_plans, [:plannable_type, :plannable_id]
  end
end
