**Troubleshooting Kubernetes Controller / Scheduler Pods**
Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

**Context**
After a cluster migration, this controlplane's kube-controller-manager & kube-scheduler pods are not coming up.  


**Objectives**
* Fix the kube **Controller** & **Scheduler** issue by reading the **Pod description** events
* Update the **Static Manifests** to a reasonable value