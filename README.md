# Dayspring IPL Prediction

Rails app for IPL match predictions with:

- email/password signup and login
- queued password reset delivery
- signup restricted to `@dayspringlabs.com` and `@dayspring.tech`
- daily match view with date selection
- prediction questions per match
- automatic lock once a match starts
- per-question result publication and scoring
- paginated personal prediction history
- leaderboard scoring based on correct answers
- paginated leaderboard
- admin tools for matches, questions, schedule import, result entry, and activity auditing

## Prerequisites

- Ruby `3.4.9`
- Rails `8.1.3`
- PostgreSQL

The repository now includes a `.ruby-version` file, so `rbenv` users should automatically pick the correct Ruby inside the project directory.

## Local setup

Start PostgreSQL locally with Docker Compose:

```bash
DB_PORT=5436 docker compose up -d postgres
```

Then point Rails at the same host port:

```bash
export DB_HOST=127.0.0.1
export DB_PORT=5436
export DB_USERNAME=postgres
export DB_PASSWORD=postgres
export DB_NAME=dayspring_ipl_prediction_development
export DB_TEST_NAME=dayspring_ipl_prediction_test
export SEED_ADMIN_PASSWORD=choose_a_seed_admin_password
export SEED_USER_PASSWORD=choose_a_seed_user_password
```

Install and boot the app:

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

Open `http://localhost:3000`.

In development, Puma will also run Solid Queue automatically. If you prefer a separate worker process, run `bin/jobs` instead of relying on the Puma plugin.

If port `5432` is free on your machine, you can omit `DB_PORT=5436` and use the default `5432`.

## Production environment

Set these environment variables in production:

```bash
export APP_HOST=predictions.example.com
export APP_PROTOCOL=https
export MAILER_FROM_EMAIL=noreply@example.com
export SMTP_ADDRESS=smtp.example.com
export SMTP_PORT=587
export SMTP_USERNAME=your_smtp_username
export SMTP_PASSWORD=your_smtp_password
export SMTP_DOMAIN=example.com
export SMTP_AUTHENTICATION=plain
export SMTP_ENABLE_STARTTLS_AUTO=true
export SENTRY_DSN=https://your-dsn.ingest.sentry.io/project
export SENTRY_ENVIRONMENT=production
export SENTRY_TRACES_SAMPLE_RATE=0
export JOB_CONCURRENCY=1
```

Notes:

- On Railway, `APP_HOST` is optional if the service has public networking enabled and `RAILWAY_PUBLIC_DOMAIN` is available.
- On Railway Postgres, `DATABASE_URL` is supported directly.
- If you run only one Railway service, set `SOLID_QUEUE_IN_PUMA=1` to run jobs in the web process. Otherwise deploy a separate worker that runs `bin/jobs`.

Run both the web process and the Solid Queue worker process in production:

```bash
bin/rails server
bin/jobs
```

## Verification

Useful checks after setup or dependency changes:

```bash
bin/rails zeitwerk:check
bin/rails test
bin/rails test:system
RAILS_ENV=development bin/rails db:drop db:create db:migrate db:seed
SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile
docker build -t dayspring-ipl-prediction .
```

The repository now includes:

- `docker-compose.yml` for a local PostgreSQL service
- `.github/workflows/ci.yml` for Rails boot, seed smoke, test, and system-test checks
- Solid Queue configuration in `config/queue.yml` and `bin/jobs`
- Sentry initialization in `config/initializers/sentry.rb`

`bin/rails db:prepare`, `bin/rails test`, and `bin/rails test:system` require a running PostgreSQL instance. `db:prepare` will also run seeds on a fresh database, so keep `SEED_ADMIN_PASSWORD` and `SEED_USER_PASSWORD` set when bootstrapping a new environment.

## Seeded accounts

`db/seeds.rb` creates these users:

- `admin@dayspringlabs.com` with the password from `SEED_ADMIN_PASSWORD`
- `fan@dayspring.tech` with the password from `SEED_USER_PASSWORD`

## Main screens

- `/` shows the selected match day, match cards, prediction questions, and the top leaderboard strip
- `/prediction_history` shows past picks, graded results, and points earned
- `/leaderboards` shows the full points table
- `/password_resets/new` starts the password reset flow
- `/admin` lets admins create/archive matches, manage questions/options, import schedules, and publish correct options
- `/admin/prediction_submissions` shows the paginated, filterable prediction audit log
- `/admin/activity_logs` shows append-only admin content audit history

## Admin bootstrap

For non-seeded environments, create or promote the first admin with:

```bash
ADMIN_EMAIL=admin@dayspringlabs.com ADMIN_PASSWORD=choose_a_password bin/rails admin:bootstrap
```

## Notes

- Each question carries its own point value
- Users must answer every currently open question for a match before picks can be saved
- Users can submit or update picks only before the match start time and before a question result is published
- Once a correct option is published for a question, the result is shown on the dashboard and in prediction history
- Admin accounts are excluded from the public leaderboard
- Password reset emails are enqueued and delivered asynchronously through Solid Queue
- In development without SMTP configured, emails are written to `tmp/mails`
