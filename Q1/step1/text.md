**CKA Lab 01: postgres Persistent Volume Recovery**

### Tasks to Perform

A PersistentVolume already exists and is retained for reuse. Only one PV exists in the cluster.

### Tasks

Create a **PersistentVolumeClaim (PVC)** named `postgres`{{copy}} in the `postgres`{{copy}} namespace with the following specifications:

* **Access Mode:** `ReadWriteOnce`{{copy}}
* **Storage:** `250Mi`{{copy}}

Edit the **postgres Deployment file** located at `~/deployment.yaml`{{copy}} to use the PVC created in the previous step.

Apply the updated **Deployment file** to the cluster.

Verify that the **postgres Deployment** is running and stable.
