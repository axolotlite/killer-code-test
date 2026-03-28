**CKA Lab 14: StorageClass Configuration**

### Tasks

Create a **new StorageClass** named `custom-storage`, make it the default Storage Class in the cluster.

* **Provisioner:** `rancher.io/local-path`{{copy}}  
* **VolumeBindingMode:** `WaitForFirstConsumer`{{copy}}  
* **Do not modify** any existing deployment or PVC

Ensure `custom-storage` is the **ONLY** default StorageClass  

