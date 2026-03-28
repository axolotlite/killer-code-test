**Troubleshooting Kubernetes API Server**
Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

**Context**
After a cluster migration, this controlplane's kube-api server is not coming up.  

Previously the etcd server was external, after the migration the etcd server has been moved to the kubernetes controlplane as a `static pod`.  

**Objectives**
* Fix the **etcd connectivity** issue
* Fix the kube **Controller** & **Scheduler** issue
* Deploy image to the default namespace