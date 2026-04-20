**Postgres Persistent Volume Recovery**
Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

You can inspect the pods / deployments in the `postgres` namespace.
`kubectl get pods -n postgres`{{copy}}

**Context**  
A user will "accidentally" delete the postgres Deployment in the `postgres` namespace.  
This deployment had been configured with persistent storage.  
Your responsibility is to restore the deployment while preserving the data by reusing the available PersistentVolume.  

**Objectives**

* Remove the **existing Claim** from the existing PV  
* Create a new PVC  
* Update the **Deployment** to use the **new PVC**  

You can use the documentation:
- https://kubernetes.io/

keyword:  
* `pvc`  

page `Persistent Volumes - Kubernetes`  
page keywords:  
* `kind: Pod`  
* `kind: PersistentVolume`  