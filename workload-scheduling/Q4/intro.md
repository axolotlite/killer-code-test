**CKA Lab 04: Resource Allocation**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

### Resource Allocation

**Context**
You are managing a WordPress application with 3 replicas. You need to adjust **resource requests and limits** to ensure stable operation.

**Objectives**

* Configure **CPU and memory requests and limits**
* Distribute node resources **evenly among pods**
* Apply the **same resources to init containers**

You can use the documentation:  
- https://kubernetes.io/

keyword:  
* `limits`  

page `Resource Management for Pods and Containers - Kubernetes`  
page keywords:  
* `kind: Pod`  
* `resources:`  