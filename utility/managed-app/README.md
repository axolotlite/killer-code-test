# Managed App - 3-Tier Store Application

A simple 3-tier application for a Kubernetes lab exercise.

## Architecture

```
┌──────────┐      ┌──────────┐      ┌──────────┐
│ Frontend │─────▶│ Backend  │─────▶│ Database │
│ (Flask)  │      │ (Flask)  │      │(Postgres)│
│ :8080    │      │ :5000    │      │ :5432    │
└──────────┘      └──────────┘      └──────────┘
```

- **Frontend**: Python/Flask web dashboard that displays products, orders, and stats
- **Backend**: Python/Flask REST API that queries the database
- **Database**: PostgreSQL 16 initialized with dummy data via SQL script (no app migrations)

## Configuration

### Backend Environment Variables
| Variable      | Description       | Default       |
| ------------- | ----------------- | ------------- |
| `DB_HOST`     | Database hostname | `database`    |
| `DB_PORT`     | Database port     | `5432`        |
| `DB_NAME`     | Database name     | `appdb`       |
| `DB_USER`     | Database user     | `appuser`     |
| `DB_PASSWORD` | Database password | `apppassword` |

### Frontend Environment Variables
| Variable       | Description      | Default   |
| -------------- | ---------------- | --------- |
| `BACKEND_HOST` | Backend hostname | `backend` |
| `BACKEND_PORT` | Backend port     | `5000`    |

## Local Testing

```bash
docker compose up --build
```

Then open http://localhost:8080 to see the dashboard.

## API Endpoints

- `GET /api/health` - Backend health check
- `GET /api/products` - List all products
- `GET /api/orders` - List all orders with items
- `GET /api/stats` - Dashboard statistics
