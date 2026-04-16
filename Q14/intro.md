**StorageClass Configuration**
Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

### StorageClass Configuration

**Context**
You need to create a **new StorageClass** and configure it as the **default** for the cluster.

**Objectives**

* Create a **StorageClass** with a specific **provisioner**
* Configure the **VolumeBindingMode**
* Manage **default StorageClass** settings

You can use the documentation:
- https://kubernetes.io/

keyword:  
* `storage class`  

page `Storage Classes | Kubernetes`  
page keywords:  
* `kind: storage`  