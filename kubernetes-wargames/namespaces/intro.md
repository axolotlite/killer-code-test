## Game 2: Namespaces & Workloads

Welcome to the Kubernetes Games.  

This game focuses on the **Namespaces** & **Workloads**:  
* kube-system: main system namespace in kubernetes  
* Workload types such as:
  * Replicasets
  * Statefulsets
  * Deployments
  * Daemonset
  * Pods

You are tasked with bringing down the cluster, you need to delete the static manifests to stop the kube-api  

You can inspect their status at anytime by running:  
`kubectl get nodes`  