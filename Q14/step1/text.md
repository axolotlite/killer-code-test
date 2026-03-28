**CKA Lab 14: StorageClass Configuration**

### Tasks

1. **Create a StorageClass** named `custom-storage`:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: custom-storage
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
# Do NOT set as default initially
```

Apply it:

```bash
kubectl apply -f custom-storage.yaml
```

2. **Patch the StorageClass** to make it the default:

```bash
kubectl patch storageclass custom-storage \
  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

3. **Ensure `custom-storage` is the ONLY default StorageClass**:

* List StorageClasses and check annotations:

```bash
kubectl get sc
```

* If another StorageClass is marked default, patch it to remove the annotation:

```bash
kubectl patch storageclass <other-sc-name> \
  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

---

### Useful Commands

```bash
# List all StorageClasses
kubectl get sc

# Patch StorageClass annotations
kubectl patch storageclass <name> -p '...'
```

💡 **Hint:** The default StorageClass is controlled via the annotation:

```yaml
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
```
