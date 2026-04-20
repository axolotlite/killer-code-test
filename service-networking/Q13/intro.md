**Network Policy Selection**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

### Network Policy Selection

**Context**
Two deployments exist: **Frontend** (`namespace: frontend`) and **Backend** (`namespace: backend`).  
You need to analyze several **NetworkPolicies** and select the **least permissive** one.

**Objectives**

* Analyze **NetworkPolicies**  
* Understand **namespaceSelector** and **podSelector**  
    * Compare **labels** and **selectors**  
    * Understand **AND/OR** Condition in the **Network Polciy**  
* Apply the **principle of least privilege** when allowing traffic
