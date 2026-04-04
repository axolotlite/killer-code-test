**CKA Lab 05: Horizontal Pod Autoscaler (HPA)**

### Tasks

Create a **HorizontalPodAutoscaler** named `apache-server` in the `autoscale` namespace.

**Specifications:**

* **Target deployment:** `apache-deployment` in `autoscale`
* **CPU target:** 50% per pod
* **Replicas:**  
  * Minimum: 1 pod  
  * Maximum: 4 pods  

* **Downscale stabilization:** 30 seconds
