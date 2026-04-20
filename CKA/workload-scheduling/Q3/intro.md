**CKA Lab 03: Sidecar Container Pattern**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

### Sidecar Container Pattern

**Context**
An nginx deployment exists and writes logs to a file. You need to add a **colocated container** to stream these logs.

**Objectives**

* Understand the **sidecar pattern**
* Use **shared volumes** between containers
* Modify an **existing deployment**

**Notes**
The documentation uses **InitContainers** instead of **colocated**(containers in the spec.container array) containers.  

You can use the documentation:
- https://kubernetes.io/

keyword:  
* `sidecar`  

**Sidecar Containers | Kubernetes**  
page keywords:  
* `kind:`
* `initContainers:`