**CKA Lab 16: NodePort Service**

### Tasks
The following should be done in the `relative` namespace  
1. **Configure the deployment** `nodeport-deployment` to expose containerPort `80`:
* **Name:** `http`
* **Port:** `80`
* **Protocol:** `TCP`
2. **Create a NodePort Service** named `nodeport-service`:
* **Port:** `80`
* **Protocol:** `TCP`
* **NodePort:** `30080`