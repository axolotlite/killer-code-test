**Backend Configuration**

The backend deployment (`store-backend`) needs environment variables to connect to the database service.

Edit the **Deployment** `store-backend` and add the following environment variables:

| Variable      | Value          |
| ------------- | -------------- |
| `DB_HOST`     | `database-svc` |
| `DB_PORT`     | `5432`         |
| `DB_NAME`     | `appdb`        |
| `DB_USER`     | `appuser`      |
| `DB_PASSWORD` | `apppassword`  |

**Hint:**
```bash
kubectl edit deployment store-backend
```

Add environment variables under `.spec.template.spec.containers[0].env`:
```yaml
env:
- name: DB_HOST
  value: "database-svc"
- name: DB_PORT
  value: "5432"
- name: DB_NAME
  value: "appdb"
- name: DB_USER
  value: "appuser"
- name: DB_PASSWORD
  value: "apppassword"
```
