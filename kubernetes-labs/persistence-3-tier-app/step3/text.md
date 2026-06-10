**Frontend Configuration**

The frontend deployment (`store-frontend`) needs environment variables to connect to the backend service.

Edit the **Deployment** `store-frontend` and add the following environment variables:

| Variable       | Value         |
| -------------- | ------------- |
| `BACKEND_HOST` | `backend-svc` |
| `BACKEND_PORT` | `5000`        |

**Hint:**
```bash
kubectl edit deployment store-frontend
```

Add environment variables under `.spec.template.spec.containers[0].env`:
```yaml
env:
- name: BACKEND_HOST
  value: "backend-svc"
- name: BACKEND_PORT
  value: "5000"
```
