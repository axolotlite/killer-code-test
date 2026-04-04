**CKA Lab 07: PriorityClass**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

### PriorityClass

**Context**
You are working in a cluster with an existing deployment `busybox-logger`. The cluster already has at least one **user-defined PriorityClass**.

**Objectives**

* Understand **PriorityClasses**
* Create a new **PriorityClass** with the correct value
* Apply a **PriorityClass** to an existing deployment

You can use the documentation:  
- https://kubernetes.io/

keyword:  
* `priority`  

page `Pod Priority and Preemption - Kubernetes`  
keywords:  
* `kind: Priority`  
* `kind: Pod`  