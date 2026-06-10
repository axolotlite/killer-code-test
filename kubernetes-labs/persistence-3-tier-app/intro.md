**3 Tier App - Configuration & Persistence**

This lab builds on the previously deployed 3-tier application. The deployments and services are already running, but the application is not functional yet.

## Architecture

```
┌──────────┐      ┌──────────┐      ┌──────────┐
│ Frontend │─────▶│ Backend  │─────▶│ Database │
│ (Flask)  │      │ (Flask)  │      │(Postgres)│
│ :8080    │      │ :5000    │      │ :5432    │
└──────────┘      └──────────┘      └──────────┘
```

## Current State
- All deployments and services are created
- A **PersistentVolume** (`db-data-pv`) already contains pre-seeded database data from a previous initialization
- The **PVC** (`db-data-pvc`) is bound to that PV
- However, the application is not configured — environment variables are missing and the database StatefulSet is not using the PVC

## Your Tasks
1. Configure the database environment variables
2. Configure the backend to connect to the database
3. Configure the frontend to connect to the backend
4. Verify the frontend is accessible (but shows empty data)
5. Attach the PVC with pre-seeded data to the database StatefulSet
6. Verify the frontend now shows data