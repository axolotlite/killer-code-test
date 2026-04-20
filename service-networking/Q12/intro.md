**CKA Lab 12: Ingress Configuration**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

### Ingress Configuration

**Context**
An **Echo Server deployment** exists in the `echo-app` namespace. You need to **expose it** via a **Service** and **Ingress**.

**Objectives**

* Create a **NodePort Service**
* Configure an **Ingress** with **path-based routing**
* Test **accessibility** of the application

You can use the documentation:  
- https://kubernetes.io/

keyword:  
* `ingress`  

page `Ingress - Kubernetes`  
page keywords:  
* `kind: Ingress`  
* `host:`