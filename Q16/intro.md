**CKA Lab 16: NodePort Service**

### NodePort Service

**Context**
A deployment `nodeport-deployment` exists in the `relative` namespace. You need to configure it to be exposed via **NodePort**.

**Objectives**

* Configure **ports** in the deployment
* Create a **NodePort Service** with a specific port
* Understand the relationship between **targetPort**, **port**, and **nodePort**

You can use the documentation:  
- https://kubernetes.io/

keyword:  
* `services`  

page `Service | Kubernetes`  
keywords:  
* `kind: Pod`  
* `containerPort:`  