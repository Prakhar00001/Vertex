<div align="center">

# ❖ V E R T E X
### Enterprise Multi-Tenant Collaboration Engine & Work Management Platform

[![Ruby](https://img.shields.io/badge/Ruby-3.2.3-CC342D?style=for-the-badge&logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-7.1.3-D30001?style=for-the-badge&logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16.0-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Redis](https://img.shields.io/badge/Redis-7.2-DC382D?style=for-the-badge&logo=redis&logoColor=white)](https://redis.io/)
[![Sidekiq](https://img.shields.io/badge/Sidekiq-7.2-B91C1C?style=for-the-badge&logo=sidekiq&logoColor=white)](https://sidekiq.org/)
[![TailwindCSS](https://img.shields.io/badge/Tailwind-3.4-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)](https://tailwindcss.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

<p align="center">
  <b>Vertex</b> is a high-throughput, multi-tenant collaboration SaaS platform architected for modern software teams.
  <br />
  Modeled after the ergonomics of <b>Linear</b> and the modular workspace isolation of <b>Basecamp</b>, Vertex features strictly scoped tenancy, RBAC enforcement, interactive kanban workflows, asynchronous event queues, and a versioned REST API.
</p>

---

[Key Highlights](#-key-highlights) • 
[System Architecture](#-system-architecture) • 
[Multi-Tenancy Model](#-multi-tenancy-isolation-model) • 
[Directory Structure](#-repository-structure) • 
[Database Schema](#-database-architecture--erd) • 
[API Reference](#-restful-api-v1) • 
[Local Setup](#-local-deployment--development-runbook) • 
[Testing Strategy](#-testing--quality-assurance)

</div>

---

## ⚡ Key Highlights

* **Path-Scoped Strict Multi-Tenancy (`/o/:org_slug/...`)**
  * Zero-leak data isolation enforced at the routing, application controller, and database index levels.
  * Thread-safe contextual state binding via `ActiveSupport::CurrentAttributes` (`Current.user`, `Current.organization`, `Current.membership`).
* **Role-Based Access Control (RBAC)**
  * Granular operational policy gates managed via **Pundit**.
  * Dynamic permissions matrix differentiating **Owners**, **Admins**, and **Members**.
* **Interactive Kanban Board**
  * Vanilla Drag-and-Drop integration synchronized with RESTful persistence endpoints (`PATCH /move`).
  * Instant status column reassignment with transactional index rebalancing.
* **Asynchronous Event-Driven Services**
  * Non-blocking background worker infrastructure powered by **Redis** and **Sidekiq**.
  * Audited activity trails (`activity_logs`) capturing changes across projects and task assignments.
* **First-Class Developer API (`/api/v1`)**
  * Fully authenticated JSON API using persistent `Bearer` API tokens and tenant header inspection (`X-Organization-Slug`).
* **Containerized Deployment Architecture**
  * Production-parity `docker-compose.yml` defining synchronized definitions for Rails 7, PostgreSQL 16, Redis 7, and Sidekiq worker pools.

---

## 🏛 System Architecture

Vertex implements a layered service architecture that keeps the controller layer thin, abstracts transactional domain business logic into dedicated services, and maintains authorization invariants via policies:

┌─────────────────────────┐
                            │       HTTP Client       │
                            │ (Browser / REST API v1) │
                            └────────────┬────────────┘
                                         │
                                         ▼
                      ┌──────────────────────────────────────┐
                      │    Reverse Proxy / Load Balancer     │
                      └──────────────────┬───────────────────┘
                                         │
                                         ▼
   ┌────────────────────────────────────────────────────────────────────────┐
   │                       Rails Application Layer                          │
   │                                                                        │
   │  ┌────────────────────────┐          ┌──────────────────────────────┐  │
   │  │   Authenticate User    ├─────────►│    Resolve Tenant Context    │  │
   │  │  (Devise / API Token)  │          │    (Current.organization)    │  │
   │  └────────────────────────┘          └──────────────┬───────────────┘  │
   │                                                     │                  │
   │                                                     ▼                  │
   │  ┌────────────────────────┐          ┌──────────────────────────────┐  │
   │  │  Domain Service Layer  │◄─────────┤ Pundit Policy Authorization  │  │
   │  │ (Tasks::CreateService) │          │   (Owner / Admin / Member)   │  │
   │  └───────────┬────────────┘          └──────────────────────────────┘  │
   │              │                                      │                  │
   └──────────────┼──────────────────────────────────────┼──────────────────┘
                  │                                      │
                  ▼                                      ▼
   ┌─────────────────────────────┐        ┌─────────────────────────────┐
   │  PostgreSQL 16 (Relational) │        │      Redis 7 (Job Queue)    │
   │  ────────────────────────── │        │  ────────────────────────── │
   │  • Strict Tenant Scopes     │        │  • Pub/Sub Buffer           │
   │  • Foreign Key Cascades     │        │  • Cache Store              │
   │  • JSONB Audit Metadata     │        │  • Asynchronous Backgrounds │
   └─────────────────────────────┘        └──────────────┬──────────────┘
                                                         │
                                                         ▼
                                          ┌─────────────────────────────┐
                                          │   Sidekiq Worker Process    │
                                          │  ────────────────────────── │
                                          │  • Transactional Mailers    │
                                          │  • Webhook Dispatchers      │
                                          │  • Audit Log Fanout Queue   │
                                          └─────────────────────────────┘


## 🔒 Multi-Tenancy Isolation Model

Multi-tenancy in Vertex uses path-based routing combined with explicit active tenant context binding:

1. **Routing Scoping**: Every tenant-bound resource lives under the URL space `/o/:org_slug/...`.
2. **Context Resolution**: The `TenantController` intercepts every request, locates the requested organization inside `current_user.organizations`, and registers it into thread-local storage:
   ```ruby
   Current.organization = current_user.organizations.find_by!(slug: params[:org_slug])
   Current.membership   = current_user.memberships.find_by!(organization: Current.organization)

1. Query Scoping: Database calls are never executed globally. Queries originate directly from the scoped associations:

# Prohibited (Vulnerable to Cross-Tenant Leakage)
@project = Project.find(params[:id])

# Standard Vertex Scoping (Airtight Isolation)
@project = Current.organization.projects.find(params[:id])

2. Database-Level Defense: Tenant tables contain organization_id NOT NULL with compound indexes ([organization_id, id], [organization_id, key]), stopping data leakage at the storage engine level.

📁 Repository Structure

Vertex/
├── .dockerignore                            # Container build exclusions
├── .env.example                             # Local environment defaults
├── .gitignore                               # SCM tracking rules
├── Dockerfile                               # Production-ready Ruby 3.2.3 container specification
├── Gemfile                                  # Curated Ruby dependency suite
├── Gemfile.lock                             # Locked gem versions
├── README.md                                # Platform documentation
├── docker-compose.yml                       # Multi-service stack (Rails, PG, Redis, Sidekiq)
│
├── app/
│   ├── assets/                              # Tailwind CSS pipelines & image manifests
│   ├── controllers/
│   │   ├── api/v1/                          # Token-authenticated REST controllers
│   │   │   ├── base_controller.rb
│   │   │   ├── organizations_controller.rb
│   │   │   ├── projects_controller.rb
│   │   │   └── tasks_controller.rb
│   │   ├── users/                           # Devise session & registration overrides
│   │   ├── application_controller.rb        # Pundit error handling & global user binding
│   │   ├── comments_controller.rb           # Issue comment thread management
│   │   ├── dashboard_controller.rb          # Aggregated overview analytics
│   │   ├── memberships_controller.rb        # RBAC user provisioning
│   │   ├── organizations_controller.rb      # Workspace lifecycle
│   │   ├── projects_controller.rb           # Project board management
│   │   ├── tasks_controller.rb              # Kanban actions, filtering, and reordering
│   │   └── tenant_controller.rb             # Scoped tenant lifecycle controller
│   ├── javascript/                          # Front-end controllers and jQuery event hooks
│   ├── mailers/                             # Asynchronous notification mailers
│   ├── models/                              # Domain models, validations, and lifecycle callbacks
│   ├── policies/                            # Pundit authorization policies (RBAC matrices)
│   ├── services/                            # Reusable transactional domain services
│   │   ├── activity_logger.rb               # Synchronous/asynchronous audit trail generator
│   │   ├── notification_service.rb          # Notification dispatch orchestration
│   │   └── tasks/
│   │       ├── task_creation_service.rb     # Issue creation and position computation
│   │       └── task_reorder_service.rb      # Kanban drag-and-drop state reconciliation
│   ├── views/                               # Tailwind-styled responsive templates
│   └── workers/                             # Sidekiq background execution workers
│
├── config/
│   ├── environments/                        # Rails environment configurations (dev, test, prod)
│   ├── initializers/                        # Devise, Pagy, Sidekiq, and ActiveStorage configs
│   ├── application.rb                       # Framework defaults & queue adapter declarations
│   ├── database.yml                         # Connection pooling & DB parameters
│   ├── routes.rb                            # Path-scoped & API route declarations
│   └── sidekiq.yml                          # Queue concurrency & priority weights
│
├── db/
│   ├── migrate/                             # Schema definitions & composite indexes
│   ├── schema.rb                            # Canonical compiled database representation
│   └── seeds.rb                             # Deterministic demo workspace seed script
│
└── spec/                                    # RSpec test automation suite
    ├── factories/                           # FactoryBot domain definitions
    ├── models/                              # ActiveRecord unit specifications
    ├── policies/                            # Pundit policy validation specs
    └── requests/                            # Integration & API endpoint specs

📊 Database Architecture & ERD

┌──────────────────┐       1:N       ┌──────────────────┐       1:N       ┌──────────────────┐
│  organizations   ├────────────────►│     projects     ├────────────────►│      tasks       │
└────────┬─────────┘                 └────────┬─────────┘                 └────────┬─────────┘
         │                                    │                                    │
         │ 1:N                                │ 1:N                                │ 1:N
         ▼                                    ▼                                    ▼
┌──────────────────┐                 ┌──────────────────┐                 ┌──────────────────┐
│   memberships    │                 │      teams       │                 │     comments     │
└────────┬─────────┘                 └──────────────────┘                 └──────────────────┘
         │
         │ N:1
         ▼
┌──────────────────┐       1:N       ┌──────────────────┐
│      users       ├────────────────►│  activity_logs   │
└──────────────────┘                 └──────────────────┘


Core Relations & Access Controls
Organizations: Root tenant node with unique lowercase URL slug (acme-corp).

Memberships: Many-to-many join between Users and Organizations, defining the tenant-level RBAC role (owner, admin, member).

Projects: Group tasks under a unique 2-6 character identifier prefix (e.g., COR-101).

Tasks: Track status (backlog, todo, in_progress, review, done), priority levels (low, medium, high, urgent), assignees, and kanban positioning.

Activity Logs: Polymorphic audit records capturing who modified which entity, complete with JSONB state diffs.


📡 RESTful API (v1)

Vertex provides a clean, token-authenticated REST API for programmatic integrations.

Authentication & Tenant Scoping

Include your user API token as a Bearer token and supply the organization slug via the X-Organization-Slug header:

Authorization: Bearer <your_api_token>
X-Organization-Slug: vertex-labs
Content-Type: application/json


| Method | Endpoint                             | Description                                      | Permitted Roles   |
| :----- | :----------------------------------- | :----------------------------------------------- | :---------------- |
| `GET`  | `/api/v1/organizations`              | List all organizations for authenticated user    | Any Authenticated |
| `GET`  | `/api/v1/organizations/:id`          | Show current organization metadata               | Org Member        |
| `GET`  | `/api/v1/projects`                   | List all projects within the tenant              | Org Member        |
| `POST` | `/api/v1/projects`                   | Create a new project in the workspace            | Admin, Owner      |
| `GET`  | `/api/v1/projects/:project_id/tasks` | Retrieve all issues for a given project          | Org Member        |
| `POST` | `/api/v1/projects/:project_id/tasks` | Create a new issue under a project               | Org Member        |


Example: Creating an Issue via cURL

curl -X POST http://localhost:3000/api/v1/projects/1/tasks \
  -H "Authorization: Bearer 93a8d42d38e21183cfbb9523293e8785" \
  -H "X-Organization-Slug: vertex-labs" \
  -H "Content-Type: application/json" \
  -d '{
    "task": {
      "title": "Upgrade Redis cluster memory thresholds",
      "description": "Adjust maxmemory settings in redis.conf for production nodes.",
      "status": "todo",
      "priority": "high",
      "due_date": "2026-10-01"
    }
  }'

🚀 Local Deployment & Development Runbook
Prerequisites

-> Docker Desktop (Engine 24.0+ / Compose v2.20+)

-> Git (2.30+)  

One-Command Boot
1. Clone the repository:

git clone [https://github.com/Prakhar00001/Vertex.git](https://github.com/Prakhar00001/Vertex.git)
cd Vertex


2. Spin up the containerized infrastructure:

docker compose up -d --build

## This starts four services in the background:

web: Rails application server (Puma on port 3000)

db: PostgreSQL 16 database server (port 5432)

redis: In-memory datastore & job queue broker (port 6379)

sidekiq: Asynchronous task processing worker

3. Initialize the database and load deterministic demo seeds:

docker compose exec web bin/rails db:prepare db:seed

4. Access the application:

Navigate to http://localhost:3000 in your browser.

## Default Seed Credentials

| Role     | Email              | Password       | Pre-configured Workspace       |
| :------- | :----------------- | :------------- | :----------------------------- |
| **Owner**| `owner@vertex.io`  | `Password123!` | Vertex Labs (`/o/vertex-labs`) |
| **Admin**| `admin@vertex.io`  | `Password123!` | Vertex Labs (`/o/vertex-labs`) |
| **Member**| `dev@vertex.io`   | `Password123!` | Vertex Labs (`/o/vertex-labs`) |

🧪 Testing & Quality Assurance

Vertex maintains a clean, isolation-focused test suite written with RSpec, FactoryBot, and Shoulda Matchers:

docker compose exec web bundle exec rspec

Test Coverage Highlights

* Model Validations & Callbacks: Ensures API token generation, key upcasing, and tenant boundary constraints.

* Pundit Policy Matrices: Guarantees that ordinary members cannot delete workspaces, alter organization ownership, or bypass tenant isolation.

* API Integration Flows: Verifies Bearer authentication, header validation, and scoped responses.


