**CKA Lab 03: Sidecar Container Pattern**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

### Sidecar Container Pattern

**Context**
A WordPress deployment exists and writes logs to a file. You need to add a **sidecar container** to stream these logs.

**Objectives**

* Understand the **sidecar pattern**
* Use **shared volumes** between containers
* Modify an **existing deployment**
