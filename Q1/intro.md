**postgres Persistent Volume Recovery**

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

You can use the documentation:
- https://kubernetes.io/