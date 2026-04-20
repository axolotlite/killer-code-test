**Horizontal Pod Autoscaler (HPA)**

### Tasks

Create a **HorizontalPodAutoscaler** named `apache-server` in the `autoscale` namespace.

**Specifications:**

* **Target deployment:** `apache-deployment` in `autoscale`
* **CPU target:** 50% per pod
* **Replicas:**  
  * Minimum: 1 pod  
  * Maximum: 4 pods  

* **Downscale stabilization:** 30 seconds

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.