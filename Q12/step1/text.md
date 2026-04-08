**CKA Lab 12: Ingress Configuration**

### Tasks

1. **Expose the Echo deployment** with a NodePort Service:
* **Name:** `echo-service`
* **Type:** `NodePort`
* **NodePort:** `31284`

2. **Create an Ingress** named `echo` in `echo-app` namespace:
* **Host:** `echo-service.org`
* **PathType:** `Prefix`
* **Path:** `/echo`
3. **Test accessibility**:

```bash
curl http://{{ exec "kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}'" }}:
```
```bash
curl http://echo-service.org/echo
```
