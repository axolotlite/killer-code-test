**CKA Lab 05: Horizontal Pod Autoscaler (HPA)**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

### Horizontal Pod Autoscaler (HPA)

**Context**
You need to create an HPA to automatically scale an **Apache Deployment** based on **CPU usage**.

**Objectives**

* Create a **HorizontalPodAutoscaler**
* Configure the **target CPU utilization**
* Define the **stabilization window** for downscaling

You can use the documentation:  
- https://kubernetes.io/

keyword:  
* `HPA`  

For full HPA Manifest:  
page `HorizontalPodAutoscaler Walkthrough - Kubernetes`  
page keywords:  
* `kind: HorizontalPodAutoscaler`  
* `scaleDown`

for Scaledown Stabilization:  
page `Horizontal Pod Autoscaling - Kubernetes`  
page keywords:  
* `behavior:`
* `scaledown:`