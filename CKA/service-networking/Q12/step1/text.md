**CKA Lab 12: Ingress Configuration**

### Tasks

1. **Expose the Echo deployment** in `echo-app` with a NodePort Service:
    * **Name:** `echo-service`
    * **Type:** `NodePort`
    * **NodePort:** `31284`

2. **Create an Ingress** named `echo` in `echo-app` namespace:
    * **Host:** `echo-service.org`
    * **PathType:** `Prefix`
    * **Path:** `/echo`
3. **Test accessibility**:

```bash
curl http://127.0.0.1:31284/echo
```{{copy}}

```bash
curl http://echo-service.org/echo
```{{copy}}

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.