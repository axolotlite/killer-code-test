**CKA Lab 17: TLS Configuration**

### Tasks
Update the deployment in the `nginx-static` namespace.  
The deployment contains a ConfigMap that supports `TLSv1.2` and `TLSv1.3`  

The deployment is exposed through a service called `nginx-service`  

1. **Modify the ConfigMap** `nginx-config` to support only **TLSv1.3** then **Restart the deployment** to apply the ConfigMap changes

2. **Add the service IP to `/etc/hosts`** and name it `ckaquestion.k8s.local`

3. **Test TLS connectivity**:
    *    `curl -vk --tls-max 1.2 https://ckaquestion.k8s.local`: should fail
    *    `curl -vk --tlsv1.3 https://ckaquestion.k8s.local`: should work

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.