**Attach Persistent Storage to Database**

A PersistentVolume (`db-data-pv`) was previously populated with database data by a data-injector job. The PVC `db-data-pvc` is already bound to it.

Your task is to configure the StatefulSet `store-db` to use this PVC so the database loads the pre-seeded data.

Edit the **StatefulSet** `store-db` and:
1. Add a volume referencing the PVC `db-data-pvc`
2. Mount it to `/var/lib/postgresql/data` in the container

**Hint:**
```bash
kubectl edit statefulset store-db
```

Add under `.spec.template.spec`:
```yaml
volumes:
- name: db-data
  persistentVolumeClaim:
    claimName: db-data-pvc
```

And under `.spec.template.spec.containers[0]`:
```yaml
volumeMounts:
- name: db-data
  mountPath: /var/lib/postgresql/data
```

After saving, delete the existing pod so the StatefulSet recreates it with the volume:
```bash
kubectl delete pod -l app=store-db
```
