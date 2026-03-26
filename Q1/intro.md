**postgres Persistent Volume Recovery**

**Context**
A user will "accidentally" delete the postgres Deployment in the `postgres` namespace. The deployment had been configured with persistent storage.

Your responsibility is to restore the deployment while preserving the data by reusing the available PersistentVolume.

**Objectives**

* Understand the lifecycle of PV/PVC
* Know how to recreate a PVC to reuse an existing PV
* Correctly configure a Deployment with persistent storage

**Environment**
The setup script has prepared:

* A namespace `postgres`
* A PersistentVolume `postgres-pv` (retained and ready to be reused)
* A Deployment template file at `~/deployment.yaml`
