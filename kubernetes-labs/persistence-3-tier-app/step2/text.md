**Backend Configuration**

The backend deployment (`store-backend`) needs environment variables to connect to the database service.

The `DB_HOST` and `DB_PORT` can be set directly, but the database credentials should reference the **Secret** `db-credentials` you created in the previous step.

Edit the **Deployment** `store-backend` and add the following environment variables:

| Variable      | Source                                        |
| ------------- | --------------------------------------------- |
| `DB_HOST`     | `database-svc` (direct value)                 |
| `DB_PORT`     | `5432` (direct value)                         |
| `DB_NAME`     | Secret `db-credentials` → `POSTGRES_DB`       |
| `DB_USER`     | Secret `db-credentials` → `POSTGRES_USER`     |
| `DB_PASSWORD` | Secret `db-credentials` → `POSTGRES_PASSWORD` |

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
  valueFrom:
    secretKeyRef:
      name: db-credentials
      key: POSTGRES_DB
- name: DB_USER
  valueFrom:
    secretKeyRef:
      name: db-credentials
      key: POSTGRES_USER
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-credentials
      key: POSTGRES_PASSWORD
```
