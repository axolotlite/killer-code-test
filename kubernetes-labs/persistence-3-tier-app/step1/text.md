**Database Configuration**

The PostgreSQL StatefulSet (`store-db`) is running but has no environment variables configured. Without these, the database container won't initialize properly.

First, create a **Secret** named `db-credentials` with the following data:

| Key                 | Value         |
| ------------------- | ------------- |
| `POSTGRES_DB`       | `appdb`       |
| `POSTGRES_USER`     | `appuser`     |
| `POSTGRES_PASSWORD` | `apppassword` |

Then edit the **StatefulSet** `store-db` to reference the secret for its environment variables using `secretKeyRef`.

**Hint:**
```bash
kubectl create secret generic db-credentials \
  --from-literal=POSTGRES_DB=appdb \
  --from-literal=POSTGRES_USER=appuser \
  --from-literal=POSTGRES_PASSWORD=apppassword
```

```bash
kubectl edit statefulset store-db
```

Add environment variables under `.spec.template.spec.containers[0].env`:
```yaml
env:
- name: POSTGRES_DB
  valueFrom:
    secretKeyRef:
      name: db-credentials
      key: POSTGRES_DB
- name: POSTGRES_USER
  valueFrom:
    secretKeyRef:
      name: db-credentials
      key: POSTGRES_USER
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-credentials
      key: POSTGRES_PASSWORD
```