**CKA Lab 10: Taints and Tolerations**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

### Taints & Tolerations

**Context**
You need to control pod scheduling using **taints** and **tolerations**.

**Objectives**

* Apply a **taint** to a node
* Create a **Pod** with the corresponding **toleration**
* Understand the effects of **NoSchedule**, **PreferNoSchedule**, and **NoExecute**

You can use the documentation:  
- https://kubernetes.io/

keyword:  
* `limits`  

page `Resource Management for Pods and Containers - Kubernetes`  
keywords:  
* `kind: Pod`  
* `resources:`  