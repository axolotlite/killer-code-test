**CKA Lab 01: Postgres Persistent Volume Recovery**

### Tasks to Perform

A PersistentVolume already exists and is retained for reuse. Only one PV exists in the cluster.

### Tasks

Create a **PersistentVolumeClaim (PVC)** named `postgres-pvc`{{copy}} in the `postgres`{{copy}} namespace with the following specifications:

* **Access Mode:** `ReadWriteOnce`{{copy}}
* **Storage:** `250Mi`{{copy}}

Edit the **postgres Deployment file** located at `~/deployment.yaml`{{copy}}  
Mount the PVC created in the previous step at `/var/lib/postgresql/data`{{copy}}

Apply the updated **Deployment file** to the cluster.

Verify that the **postgres Deployment** is running and stable.
