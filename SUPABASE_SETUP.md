# Supabase Setup Guide for NPSP Rails App — Detailed Walkthrough

This guide walks you through every step of setting up Supabase for the NPSP Rails app, with detailed instructions for each screen.

---

## Overview

You will:

1. Create a new Supabase project (or use an existing one)
2. Get the PostgreSQL connection string
3. Test the connection locally (optional)
4. Add the connection string to Render when deploying

**Time required:** About 5–10 minutes (plus 1–2 minutes for project provisioning)

---

## Part 1: Create a Supabase Project

### Step 1.1: Open the Dashboard

1. Go to **[supabase.com/dashboard](https://supabase.com/dashboard)**
2. Sign in if prompted
3. You should see your **organization** (or a list of organizations if you belong to more than one)

### Step 1.2: Start Creating a Project

1. In the left sidebar or top area, look for **"New project"** or **"New Project"**
2. Click it
3. If you have multiple organizations, you may be asked to select one — choose the organization you want this project in

### Step 1.3: Fill In the Project Form

You’ll see a form with several fields:

| Field | What to enter | Notes |
|-------|----------------|-------|
| **Organization** | (Pre-selected) | Usually your org; change only if needed |
| **Name** | `npsp-rails` or `npsp-crm` | Display name; can be changed later |
| **Database Password** | A strong password | **Critical:** Save this in a password manager. You need it for the connection string. |
| **Region** | Choose a region | See region guidance below |

#### Database Password

- Use at least 12 characters
- Mix of letters, numbers, and symbols
- **Save it now** — you’ll need it for `DATABASE_URL`
- If you lose it, you can reset it later in **Project Settings → Database**

#### Region Selection

Choose a region close to where your app will run:

- **Render (Oregon):** `West US (North California)` or `West US (Oregon)`
- **Render (Ohio):** `East US (North Virginia)` or `East US (Ohio)`
- **Render (Frankfurt):** `Europe (Frankfurt)`
- **Render (Singapore):** `Southeast Asia (Singapore)`

Closer regions reduce latency.

### Step 1.4: Create the Project

1. Click **"Create new project"** or **"Create project"**
2. Wait 1–2 minutes while Supabase provisions the database
3. You’ll see a loading/progress indicator
4. When it’s done, you’ll land on the project dashboard (Table Editor, API, etc.)

---

## Part 2: Get Your Connection String

### Step 2.1: Open the Connect Dialog

1. In the top-right of the project dashboard, find the **"Connect"** button (often with a plug or connection icon)
2. Click **Connect**
3. A panel or modal will open with connection options

**Alternative path:** Click the **gear icon** (Settings) in the left sidebar → **Database** → scroll to **Connection string**

### Step 2.2: Choose the Connection Type

In the Connect panel you’ll see tabs or options such as:

- **URI** (connection string) — **choose this**
- **JDBC**
- **.NET**
- **Node.js**
- **PHP**
- etc.

Select **URI**.

### Step 2.3: Choose Session Pooler

Below the URI option, you’ll see connection modes:

| Mode | When to use |
|------|-------------|
| **Session** (port 5432) | **Use this for Rails on Render** — persistent server, supports IPv4 |
| Transaction (port 6543) | Serverless, edge functions |
| Direct (port 5432) | Migrations, pg_dump — IPv6 only by default |

Select **Session** (or “Session pooler”).

### Step 2.4: Copy the Connection String

You’ll see a string like:

```
postgres://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@aws-0-[REGION].pooler.supabase.com:5432/postgres
```

**Example (with placeholders):**

```
postgres://postgres.abcdefghijklmnop:[YOUR-PASSWORD]@aws-0-us-east-1.pooler.supabase.com:5432/postgres
```

1. Click **Copy** (or select and copy manually)
2. Paste it into a text editor or password manager
3. Replace `[YOUR-PASSWORD]` with the database password you set in Step 1.3

**Important:** The password may contain special characters. If so, they usually don’t need URL-encoding for Rails, but if you see connection errors, try URL-encoding `@`, `#`, `%`, etc.

### Step 2.5: Add SSL (Recommended)

Append `?sslmode=require` to the end of the string:

**Before:**
```
postgres://postgres.xxxxx:yourpassword@aws-0-us-east-1.pooler.supabase.com:5432/postgres
```

**After:**
```
postgres://postgres.xxxxx:yourpassword@aws-0-us-east-1.pooler.supabase.com:5432/postgres?sslmode=require
```

This forces an encrypted connection.

### Step 2.6: Save the Final String

Store the final connection string securely. You’ll use it as:

- `DATABASE_URL` in Render
- `DATABASE_URL` in a local `.env` file for testing

---

## Part 3: Verify Project Settings (Optional)

### Step 3.1: Check Database Password

1. Click the **gear icon** (Settings) in the left sidebar
2. Go to **Database**
3. Under **Database password**, you can **Reset database password** if you’ve lost it
4. Resetting creates a new password; update `DATABASE_URL` everywhere you use it

### Step 3.2: Note Your Project ID

1. In **Settings → General**, find **Reference ID** or **Project ID**
2. It’s a short string (e.g. `abcdefghijklmnop`)
3. Useful for Supabase MCP project-scoped URLs: `?project_ref=YOUR_PROJECT_ID`

---

## Part 4: Test the Connection Locally (Optional)

Before deploying, you can confirm the connection works.

### Step 4.1: Create a `.env` File

1. In your project root (`npsp_rails_models/npsp_rails_app/`), create a file named `.env`
2. Add this line (use your real connection string):

```
DATABASE_URL=postgres://postgres.xxxxx:yourpassword@aws-0-us-east-1.pooler.supabase.com:5432/postgres?sslmode=require
```

3. Save the file — `.env` is in `.gitignore` and will not be committed

### Step 4.2: Load Environment Variables

Rails doesn’t load `.env` by default. Use one of these:

**Option A: Use `dotenv` (if installed)**

```bash
bundle add dotenv-rails --group development
```

Then create/update `.env` and run:

```bash
RAILS_ENV=production DATABASE_URL="your-connection-string" bin/rails db:migrate
```

**Option B: Export manually (no gem)**

```bash
export DATABASE_URL="postgres://postgres.xxxxx:yourpassword@aws-0-us-east-1.pooler.supabase.com:5432/postgres?sslmode=require"
RAILS_ENV=production bin/rails db:migrate
```

Replace the URL with your actual connection string.

### Step 4.3: Run Migrations

```bash
cd npsp_rails_models/npsp_rails_app
RAILS_ENV=production bin/rails db:migrate
```

If it succeeds, you’ll see output like:

```
== 20250205000001 CreateAccounts: migrating ===================================
-- create_table(:accounts)
   -> 0.0xxx s
...
```

### Step 4.4: (Optional) Seed Data

```bash
RAILS_ENV=production bin/rails db:seed
```

This loads the sample NPSP data (contacts, donations, etc.).

---

## Part 5: Add to Render

When you create or edit your Render Web Service:

1. Go to the **Environment** tab
2. Click **Add Environment Variable**
3. Set:
   - **Key:** `DATABASE_URL`
   - **Value:** Your full Supabase connection string (with password and `?sslmode=require` if you use it)
4. Save

Render will use this for the release command (`db:migrate`) and the running app.

---

## Checklist

Use this to confirm you’ve completed each step:

- [ ] Created a Supabase project
- [ ] Saved the database password
- [ ] Opened the Connect dialog
- [ ] Selected URI → Session pooler
- [ ] Copied the connection string
- [ ] Replaced `[YOUR-PASSWORD]` with the real password
- [ ] Appended `?sslmode=require` (optional but recommended)
- [ ] Tested locally with `db:migrate` (optional)
- [ ] Added `DATABASE_URL` to Render environment variables

---

## Connection String Anatomy

Understanding the parts helps with debugging:

```
postgres://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:5432/postgres?sslmode=require
│         │         │              │         │                        │     │        │
│         │         │              │         │                        │     │        └── Database name (always "postgres")
│         │         │              │         │                        │     └── Port (5432 = Session pooler)
│         │         │              │         │                        └── Supabase pooler host
│         │         │              │         └── Your database password
│         │         │              └── Username format for pooler (postgres + project ref)
│         │         └── Your project's unique reference ID
│         └── PostgreSQL username
└── Protocol
```

---

## Troubleshooting

### "Connection refused" or "Could not connect to server"

- Wait for the project to finish provisioning (1–2 minutes)
- Check the project isn’t paused (Settings → General)
- Confirm you’re using the Session pooler string (port 5432), not Transaction (6543)

### "Password authentication failed for user"

- Ensure the password in the URL matches the one in **Settings → Database**
- No extra spaces before/after the password
- Reset the password in the dashboard and update `DATABASE_URL`

### "SSL connection required"

- Add `?sslmode=require` to the end of the connection string

### Migrations fail with "relation already exists"

- Tables may already exist from a previous run
- Check status: `RAILS_ENV=production bin/rails db:migrate:status`
- For a clean slate (⚠️ deletes all data): `RAILS_ENV=production bin/rails db:drop db:create db:migrate`

### Special characters in password

If the password contains `@`, `#`, `%`, `/`, etc., URL-encode them:

| Character | Encoded |
|-----------|---------|
| `@` | `%40` |
| `#` | `%23` |
| `%` | `%25` |
| `/` | `%2F` |

Example: password `pass@word#1` → `pass%40word%231`

---

## Using the Supabase MCP

If you use the Supabase MCP in Cursor:

1. **Project-scoped URL:** Add `?project_ref=YOUR_PROJECT_ID` so the MCP only accesses this project
2. **Useful tools:**
   - `list_tables` — Verify tables after migrations
   - `execute_sql` — Run queries
   - `list_migrations` — See applied migrations
3. **Read-only mode:** For production data, consider `?read_only=true` to limit writes
