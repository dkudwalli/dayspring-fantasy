# AGENT.md

## Overview

This repository is a small server-rendered Rails app for IPL match predictions.

Current product scope:

- user signup, login, and logout
- async password reset via queued mail delivery
- daily match dashboard with date selection
- prediction questions per match
- automatic lock when a match starts or a question result is published
- per-question result declaration and point scoring
- paginated prediction history and graded breakdown
- paginated leaderboard with admin accounts excluded
- admin area for matches, questions, options, schedule import, prediction audit logs, and admin activity logs

## Stack

- Ruby `3.4.9` in `Gemfile`
- Rails `8.1.3` with importmap, Turbo, Stimulus, Sprockets, ERB
- PostgreSQL
- `bcrypt` for password auth
- Rails signed tokens for password reset
- Solid Queue for background jobs
- Sentry for exception reporting
- no API layer; HTML-first app
- Action Mailer SMTP configuration driven by env vars
- no realtime features in active use

Environment notes:

- `config/application.rb` sets `config.time_zone = "Kolkata"`
- display helpers use `Asia/Kolkata` in `app/helpers/application_helper.rb`
- `.ruby-version` pins the repo to Ruby `3.4.9`
- `config/application.rb` now uses `config.load_defaults 8.1`
- the Docker build has been validated on Ruby `3.4.9`, and the build stage needs `libyaml-dev` for the current gem set

## Main Entry Points

- dashboard: `app/controllers/dashboard_controller.rb`
- auth: `app/controllers/sessions_controller.rb`, `app/controllers/registrations_controller.rb`
- prediction save flow: `app/controllers/predictions_controller.rb`
- leaderboard: `app/controllers/leaderboards_controller.rb`
- admin: `app/controllers/admin/*`
- scoring rules: `app/models/user.rb`, `app/models/prediction.rb`
- lock rules: `app/models/match.rb`, `app/models/prediction_question.rb`, `app/models/prediction.rb`
- main UI: `app/views/dashboard/index.html.erb`
- admin UI: `app/views/admin/**/*`
- client-side prediction form behavior: `app/javascript/controllers/prediction_form_controller.js`

## Data Model

- `User`
  - email/password auth via `has_secure_password`
  - boolean `admin`
  - email domain allowlist validation
  - owns `predictions` and `prediction_submissions`
- `Match`
  - teams, venue, start time
  - optional `archived_at`
  - has many `prediction_questions`
  - considered locked once `starts_at <= Time.current`
- `PredictionQuestion`
  - belongs to a `match`
  - prompt, `point_value`, optional `correct_option_id`
  - optional `archived_at` and `result_published_at`
  - owns `options`, `predictions`, and `prediction_submissions`
- `PredictionOption`
  - belongs to a question
  - selectable answer label
  - optional `archived_at` and explicit `position`
- `Prediction`
  - one user answer per question
  - unique on `[user_id, prediction_question_id]`
  - validates that the option belongs to the question
  - validates that the question is still open
- `PredictionSubmission`
  - append-only audit row for every create/update event
  - stores user, match, question, option, action type, and timestamp
- `AdminAuditLog`
  - append-only admin content audit row
  - stores acting admin, action, auditable entity, optional match, metadata, and timestamp

## Features Present Today

### Authentication and access control

- email/password registration
- email/password login/logout
- password reset request and token-based password update
- password reset delivery via `PasswordResetDeliveryJob` on the `mailers` queue
- session-based auth via `session[:user_id]`
- admin-only namespace protected by `authenticate_admin!`
- registration restricted to `@dayspringlabs.com` and `@dayspring.tech`
- `admin:bootstrap` rake task for first-admin creation/promotion

### User-facing product

- dashboard at `/`
- auto-selects a relevant match date if no date is provided
- paginated date strip for browsing the schedule
- daily match cards with:
  - venue
  - India time formatting
  - open/locked state
  - team logos where assets exist
- per-match multi-question prediction form
- one answer required per open question before save is enabled
- existing predictions can be updated before lock
- saved picks are shown back to the user
- results display once a correct option is published
- paginated prediction history page with per-match status and per-question points
- personal score and rank shown on dashboard
- top-3 leaderboard strip on dashboard
- paginated full leaderboard page with admins excluded

### Admin features

- create/edit matches
- archive/restore matches
- CSV schedule import from the admin UI
- create/edit questions
- archive/restore questions
- enter point values per question
- create, edit, reorder, archive, and delete options
- mark the correct option and explicitly publish results
- view paginated and filterable prediction submission logs with timestamp, user, match, question, pick, and action
- view paginated and filterable append-only admin activity logs for match/question/option changes

### Supporting assets and ops

- Dockerfile for production image build
- `docker-compose.yml` for local PostgreSQL
- GitHub Actions CI in `.github/workflows/ci.yml`
- `config/queue.yml`, `config/recurring.yml`, and `bin/jobs` for Solid Queue
- `config/initializers/sentry.rb` for production error tracking
- `db/seeds.rb` with sample users and IPL-style schedule data
- `db/matches_schedule_2026.sql` for bulk schedule loading
- model, integration, routing, and system tests for core auth, prediction, scoring, admin, and history flows
- static team logo assets in `public/team_logos`

## Current Gaps and Inconsistencies Already In The Codebase

These are not hypothetical; they are present right now.

- production deployment still depends on environment provisioning outside the repo for SMTP credentials, `APP_HOST`, `MAILER_FROM_EMAIL`, and `SENTRY_DSN`
- Solid Queue is configured, but the repo does not include an in-app job dashboard or retry UI
- alert routing, escalation policy, and Sentry project rules live outside the repository and still need to be configured per deployment

## Must-Have Missing Features

These are the highest-value missing pieces for this project.

### 1. Deployment-level operations completion

- provision real SMTP credentials in each environment
- provision `APP_HOST`, `MAILER_FROM_EMAIL`, and `SENTRY_DSN`
- ensure production process management runs both the web process and `bin/jobs`

Why this matters:

- the code path exists now, but these features still depend on deployment being wired correctly

### 2. Queue operations visibility

- add a job dashboard such as Mission Control Jobs if operators need UI-based retry/discard flows
- document how to inspect failed queue jobs and recurring cleanup behavior

Why this matters:

- background jobs are now part of the app’s critical path

### 3. External observability policy

- create Sentry alert rules for mail failures and admin action failures
- document incident routing and expected owner actions

Why this matters:

- the repo now emits the right signals, but somebody still needs to operationalize them

## Suggested Order Of Work

If only a few things can be done next, do them in this order:

1. provision production SMTP and Sentry env vars
2. add a job operations dashboard or queue runbook
3. configure Sentry alert routing and incident ownership

## Verification Notes

This document was written from a direct codebase pass over models, controllers, views, routes, schema, seeds, tests, assets, and environment config.

Verification status during analysis:

- `.ruby-version` now selects Ruby `3.4.9` correctly in the project directory
- `bundle install` succeeds under Ruby `3.4.9`
- the bundle now pins Rails `8.1.3` and Bundler `2.6.9`
- `bin/rails routes -g predictions` confirms that only `POST /predictions` is exposed
- `bin/rails zeitwerk:check` passes
- `RAILS_ENV=development bin/rails db:drop db:create db:migrate db:seed` passes with seed env vars set
- `bin/rails test` passes with a PostgreSQL service available: `51 runs, 235 assertions, 0 failures, 0 errors`
- `bin/rails test:system` passes with a PostgreSQL service available

Use this when setting up locally:

```bash
DB_PORT=5436 docker compose up -d postgres
bundle install
export DB_HOST=127.0.0.1
export DB_PORT=5436
export DB_USERNAME=postgres
export DB_PASSWORD=postgres
export SEED_ADMIN_PASSWORD=choose_a_seed_admin_password
export SEED_USER_PASSWORD=choose_a_seed_user_password
export APP_HOST=localhost
export APP_PORT=3000
bin/rails db:prepare
bin/rails server
```
