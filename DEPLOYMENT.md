# NPSP Rails App — Deployment Guide (Render + Supabase)

## Prerequisites

- GitHub account
- [Supabase](https://supabase.com) account
- [Render](https://render.com) account

---

## Step 1: Set Up Supabase

See **[SUPABASE_SETUP.md](SUPABASE_SETUP.md)** for the full guide. Summary:

1. Create a project in your Supabase organization (or use an existing one).
2. In your project, go to **Connect** or **Settings → Database**.
3. Under **Connection string**, select **URI** and copy the **Session pooler** connection (port 5432).
4. Replace `[YOUR-PASSWORD]` in the URL with your actual database password.
5. Optionally append `?sslmode=require` for explicit SSL.
6. Save this URL — you'll add it as `DATABASE_URL` in Render.

---

## Step 2: Initialize Git and Push to GitHub

```bash
cd npsp_rails_app

# Initialize repo (if not already done)
git init

# Add all files
git add .

# First commit
git commit -m "Initial commit: NPSP Rails app ready for deployment"

# Create a new repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git branch -M main
git push -u origin main
```

---

## Step 3: Generate SECRET_KEY_BASE

```bash
bin/rails secret
```

Copy the output — you'll add it as `SECRET_KEY_BASE` in Render.

---

## Step 4: Deploy on Render

1. Go to [dashboard.render.com](https://dashboard.render.com) and sign in.
2. Click **New +** → **Web Service**.
3. Connect your GitHub account and select the repository containing the NPSP Rails app.
4. Configure the service:
   - **Name:** `npsp-rails-app` (or your preferred name)
   - **Region:** Choose closest to your users
   - **Branch:** `main`
   - **Runtime:** `Ruby`
   - **Build Command:** (leave default, or use)
     ```
     bundle install && bin/rails assets:precompile
     ```
   - **Start Command:** (leave default — Render uses the Procfile)
     ```
     (uses Procfile: web: bin/rails server -p ${PORT:-3000} -e production)
     ```

5. Add **Environment Variables**:
   | Key | Value |
   |-----|-------|
   | `DATABASE_URL` | Your Supabase connection string (from Step 1) |
   | `SECRET_KEY_BASE` | Output from `bin/rails secret` (Step 3) |
   | `RAILS_ENV` | `production` |
   | `RAILS_HOST` | `https://your-app-name.onrender.com` (optional; for mailer links) |

6. Under **Advanced**, set **Release Command**:
   ```
   bin/rails db:migrate
   ```
   This runs migrations before each deploy.

7. Click **Create Web Service**.

---

## Step 5: (Optional) Seed the Database

After the first successful deploy, you can seed the database with sample data:

1. In Render, open your service → **Shell** tab.
2. Run:
   ```
   bin/rails db:seed
   ```

Or use Render's **Background Worker** or a one-off job if you prefer.

---

## Step 6: Update Mailer Host (When Needed)

When you configure email (e.g., for acknowledgments), set the host in Render:

| Key | Value |
|-----|-------|
| `RAILS_HOST` | `https://your-app-name.onrender.com` |

Then in `config/environments/production.rb`, you can use:

```ruby
config.action_mailer.default_url_options = { host: ENV.fetch("RAILS_HOST", "example.com") }
```

---

## Troubleshooting

### Build fails with database error
- Ensure `DATABASE_URL` is set in Render *before* the first build.
- Check that the Supabase URL includes `?sslmode=require` if you see SSL errors.

### App crashes on boot
- Verify `SECRET_KEY_BASE` is set.
- Check Render logs for the exact error.

### Migrations don't run
- Confirm the **Release Command** is set to `bin/rails db:migrate`.
- Check that `DATABASE_URL` is correct and the database is reachable.

### 502 Bad Gateway
- The app may be slow to boot. On the free tier, Render spins down after inactivity; the first request after idle can take 30–60 seconds.
- Consider upgrading to a paid plan for always-on instances.
