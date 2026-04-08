**CKA Lab 13: Network Policy Selection**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

### Network Policy Selection

**Context**
Two deployments exist: **Frontend** (`namespace: frontend`) and **Backend** (`namespace: backend`). You need to analyze several **NetworkPolicies** and select the **least permissive** one.

**Objectives**

* Analyze **NetworkPolicies**
* Understand **namespaceSelector** and **podSelector**
* Apply the **principle of least privilege** when allowing traffic

You can use the documentation:  
- https://kubernetes.io/

keyword:  
* `TBD`  

page `TBD`  
keywords:  
* `kind:`  
* `TBD`  