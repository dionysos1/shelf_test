# Dart Shelf API with CRUD and Web UI

This is a lightweight Dart-based REST API server using [Shelf](https://pub.dev/packages/shelf), with a small HTML + [Tabulator](https://tabulator.info/) frontend for managing users in a PostgreSQL database.

## 🚀 Features

- 📦 Simple Shelf API (GET/POST/PUT/DELETE)
- 🧾 Web-based CRUD UI (`/users-ui`)
- 🔒 Optional token-based auth
- 🌐 IP-restricted access for sensitive endpoints
- 🐘 PostgreSQL database
- 🐳 Docker + Docker Compose setup
- 🧪 Basic integration tests

---

## 🛠 Setup

### 1. Clone and enter the project

```bash
git clone https://github.com/yourname/dart_api.git
cd dart_api
```

### 2. Run locally (for development)

```bash
dart pub get
dart run bin/server.dart
```

Then visit:
- Web UI: [http://localhost:8080/users-ui](http://localhost:8080/users-ui)
- API: `GET /api/users`, `POST /api/users`, etc.

---

## 🐳 Running with Docker

### 1. Build the container

```bash
docker build -t dart_api .
```

### 2. Run with Docker Compose

```bash
docker compose up -d
```

This starts both:
- Dart API server
- PostgreSQL database

---

## 🧪 Running Tests

Make sure Postgres is running locally or via Docker, then run:

```bash
dart test
```

---

## 🔐 Securing Endpoints (optional)

You can:
- Require an `Authorization` header for `/api/*`
- Restrict access to `/users-ui` and `/api/users` by IP (e.g. only 192.168.x.x)

Configure this in `users_ui.dart` via middleware.

---

## 📁 Project Structure

```
lib/
  db.dart           # DB helper (PostgreSQL)
  users_ui.dart     # CRUD UI and API routes

bin/
  server.dart       # App entrypoint

test/
  dart_api_test.dart  # Integration tests

Dockerfile
docker-compose.yml
```
