**Troubleshooting Kubernetes API Pods**
Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

**Context**
After a cluster migration, this controlplane's kube-api server is not coming up.  

Previously the etcd server was external, after the migration the etcd server has been moved to the kubernetes controlplane as a `static pod`.  

**Objectives**
* Fix the **etcd connectivity** issue by reading the cri-o logs through `crictl`
* Update the **Port** inside the etcd static manifest