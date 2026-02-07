# Salesforce NPSP → Rails Data Model Guide

## How Salesforce Concepts Map to Rails

| Salesforce Concept     | Rails Equivalent                | Example                                      |
|------------------------|----------------------------------|----------------------------------------------|
| Object                 | Model (+ database table)         | `Account` object → `Account` model + `accounts` table |
| Field                  | Column in a database table       | `Account.Name` → `name` column in `accounts` |
| Record                 | A single row in the table        | "Smith Household" → one row in `accounts`    |
| Record Type            | STI or `type` / `account_type` column | Household vs Organization                |
| Lookup Relationship    | `belongs_to` / `has_many`        | `Contact belongs_to :account`                |
| Master-Detail          | `belongs_to` + `dependent: :destroy` | `Payment belongs_to :donation` (delete donation → deletes payments) |
| Junction Object        | A join model with two `belongs_to` | `CampaignMember` joins Campaign ↔ Contact   |
| Polymorphic Lookup     | `polymorphic: true` association  | Task can belong to any model via `taskable`  |
| Rollup Summary Field   | `counter_cache` or calculated method/callback | `donations_count` on Account           |
| Picklist               | `enum` or a `string` with validations | `enum status: { active: 0, lapsed: 1 }` |
| Formula Field          | A Ruby method on the model       | `def expected_revenue; amount * probability; end` |
| Auto-Number            | Rails `id` column (auto-increment) | Every table gets this automatically        |
| Trigger / Automation   | `before_save` / `after_create` callbacks | Auto-create Household when Contact is created |

## Key Design Decisions

### 1. Account → Two models or one?
NPSP uses a single Account object with Record Types (Household vs Organization).
In Rails, you have two clean options:

**Option A: Single `accounts` table with a `type` column (STI — Single Table Inheritance)**
- Simpler, fewer tables
- `HouseholdAccount < Account` and `OrganizationAccount < Account`
- Downside: lots of nullable columns

**Option B: Single `accounts` table with an `account_type` enum** ← Recommended for simplicity
- One model, one table, use `enum account_type: { household: 0, organization: 1 }`
- Easier to query and understand

### 2. Opportunity → Renamed to `Donation`
Since this is a nonprofit CRM, we rename Opportunity to Donation — it's clearer and avoids sales jargon.

### 3. IDs
Salesforce uses 18-character string IDs. Rails uses auto-incrementing integers by default.
For a new app, stick with Rails defaults (integer or UUID if you prefer).

### 4. Rollup Fields
Salesforce auto-calculates rollups. In Rails, you can:
- Use `counter_cache: true` for simple counts
- Use `after_save` / `after_destroy` callbacks for sums and averages
- Or calculate on-the-fly with methods (simpler but slower for large datasets)

The models below use callbacks for the most important rollups.

## Model Overview

```
Account (Household / Organization)
  ├── has_many :contacts
  ├── has_many :donations (through contacts or direct)
  ├── has_many :addresses
  ├── has_many :affiliations (for organizations)
  ├── has_many :recurring_donations
  └── has_many :account_soft_credits

Contact (Constituent / Donor)
  ├── belongs_to :account (household)
  ├── has_many :donations (as primary donor)
  ├── has_many :payments (through donations)
  ├── has_many :recurring_donations
  ├── has_many :affiliations
  ├── has_many :relationships
  ├── has_many :campaign_memberships
  ├── has_many :partial_soft_credits
  └── has_many :tasks

Donation (= Salesforce Opportunity)
  ├── belongs_to :account
  ├── belongs_to :contact (primary donor)
  ├── belongs_to :campaign (optional)
  ├── belongs_to :recurring_donation (optional)
  ├── has_many :payments (master-detail: destroy dependent)
  ├── has_many :gau_allocations (fund splits)
  ├── has_many :donation_contact_roles
  └── has_many :partial_soft_credits

RecurringDonation
  ├── belongs_to :contact (or account for org donors)
  ├── has_many :donations (auto-created installments)
  └── has_many :gau_allocations

Payment
  └── belongs_to :donation (master-detail)

GeneralAccountingUnit (GAU / Fund)
  └── has_many :gau_allocations

GauAllocation (junction: links GAU to Donation/RecurringDonation/Campaign)
  ├── belongs_to :general_accounting_unit
  ├── belongs_to :donation (optional)
  ├── belongs_to :recurring_donation (optional)
  └── belongs_to :campaign (optional)

Campaign
  ├── has_many :campaign_memberships
  ├── has_many :contacts (through campaign_memberships)
  ├── has_many :donations
  └── has_many :gau_allocations

Affiliation (Contact ↔ Organization Account with role)
  ├── belongs_to :contact
  └── belongs_to :organization (Account)

Relationship (Contact ↔ Contact with type)
  ├── belongs_to :contact
  └── belongs_to :related_contact (Contact)

Address (multiple per Household)
  └── belongs_to :account

EngagementPlanTemplate → EngagementPlanTask → EngagementPlan
  (Stewardship automation)

Task (polymorphic — can attach to any record)
  ├── belongs_to :taskable (polymorphic)
  └── belongs_to :assigned_to (User)
```

## Running the Migrations

After copying these files into your Rails app:

```bash
rails db:migrate
```

## What's NOT included (you'd add later)

- User/authentication (use Devise gem)
- Authorization/roles (use Pundit or CanCanCan gem)
- Report/Dashboard models (build with charting gems)
- File attachments (use Active Storage)
- Search (use pg_search or Ransack gem)
- API endpoints (add controllers as needed)
