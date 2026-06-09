**3 Tier App Deployment**
This lab will guide you through a 3 tier application in kubernetes.  

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
You'll have to go through the steps / processes of deploying these applications on a kubernetes cluster.  
These steps are:
* Creating manifests for the applications
* Creating services for the user and the pods to communicate with each other
* Creating Configmaps and configuring persistent storage for the applications