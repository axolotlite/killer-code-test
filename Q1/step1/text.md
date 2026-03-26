**CKA Lab 01: postgres Persistent Volume Recovery**

### Tasks to Perform

A PersistentVolume already exists and is retained for reuse. Only one PV exists in the cluster.

### Tasks

Create a **PersistentVolumeClaim (PVC)** named `postgres` in the `postgres` namespace with the following specifications:

* **Access Mode:** `ReadWriteOnce`
* **Storage:** `250Mi`

Edit the **postgres Deployment file** located at `~/deployment.yaml` to use the PVC created in the previous step.

Apply the updated **Deployment file** to the cluster.

Verify that the **postgres Deployment** is running and stable.

---

### Useful Commands

```bash
# Check the existing PV
kubectl get pv

# Check PVCs
kubectl get pvc -n postgres

# Check the deployment
kubectl get deploy -n postgres
```

---

### Hint 1: PVC Structure

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres
  namespace: postgres
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi
```

---

### Hint 2: Deployment Modification

In `~/deployment.yaml`, modify:

```yaml
claimName: ""
```

to

```yaml
claimName: "postgres"
```
