**3 Tier App Deployment Part 2: Service Creation**
This lab will guide you through creating Services for the applications and for the user to access these applications.  

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

## Your tasks
You'll have to go through the steps / processes of exposing these applications for the user.  
These steps are:
* Expose the backend as ClusterIP
* Expose the database as a ClusterIP
* Expose the frontend as NodePort
* Access the exposed frontend