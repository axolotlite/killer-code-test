**CKA Lab 16: NodePort Service**

### NodePort Service

**Context**
A deployment `nodeport-deployment` exists in the `relative` namespace.  
You need to configure it to be exposed via **NodePort**.

**Objectives**

* Expose **ports** in the deployment using `kubectl export`
* Create a **NodePort Service** with a specific port
* Understand the relationship between **targetPort**, **port**, and **nodePort**

You can use the documentation:  
- https://kubernetes.io/

keyword:  
* `services`  

page `Service | Kubernetes`  
page keywords:  
* `kind: Pod`  
* `containerPort:`  