**Database Configuration**

The PostgreSQL StatefulSet (`store-db`) is running but has no environment variables configured. Without these, the database container won't initialize properly.

Edit the **StatefulSet** `store-db` and add the following environment variables to the container:

| Variable | Value |
|----------|-------|
| `POSTGRES_DB` | `appdb` |
| `POSTGRES_USER` | `appuser` |
| `POSTGRES_PASSWORD` | `apppassword` |

**Hint:**
```bash
kubectl edit statefulset store-db
```

Add environment variables under `.spec.template.spec.containers[0].env`: