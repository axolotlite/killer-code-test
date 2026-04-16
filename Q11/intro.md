**CKA Lab 11: Gateway API Migration**

### Gateway API Migration

**Context**
You have a web application with an existing **Ingress**. You need to **migrate** to the new **Gateway API** while maintaining **HTTPS configuration**.

**Objectives**

* Create a **Gateway** resource
* Create an **HTTPRoute**
* Understand the relationship between **Gateway**, **HTTPRoute**, and **Service**

You can use the gateway api documentation:  
- https://gateway-api.sigs.k8s.io/

keyword:  
* `tls conf`  

page `TLS Configuration`  
page keywords:  
* `kind: Gateway`  

You can use the documentation:  
- https://kubernetes.io/

keyword:  
* `gateway`  

page `Gateway API - Kubernetes`  
page keywords:  
* `kind: httproute`  