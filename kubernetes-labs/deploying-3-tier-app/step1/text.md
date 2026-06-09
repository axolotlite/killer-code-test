**Resource Requests and Limits**  
This 3 tier app was hosted on a VM, your tasked with creating the needed resources for this application on Kubernetes.  
Create a **Deployment** for the backend & frontend:  
* backend application
    * Name: store-backend
    * Image: ghcr.io/axolotlite/killer-code-test/managed-app/dummy-store-backend
    * Resource Requests: 
      * CPU: 0.1Mi
      * Memory: 100MB
    * Resource Limits: 
      * CPU: 0.4Mi
      * Memory: 500MB
* frontend application
    * Name: store-frontend
    * Image: ghcr.io/axolotlite/killer-code-test/managed-app/dummy-store-backend
    * Resource Requests: 
      * CPU: 0.01Mi
      * Memory: 50MB
    * Resource Requests: 
      * CPU: 0.4Mi
      * Memory: 500MB

Next create a Statefulset for the database:  
* Database
    * Name: store-db
    * Image: postgres:14.23-alpine3.23
    * Resource Requests: 
      * CPU: 0.1Mi
      * Memory: 200MB
    * Resource Requests: 
      * CPU: 0.6Mi
      * Memory: 1000MB

**Hint:**  
Use the following command to create a yaml file  
`kubectl run <pod_name> --image=<image> --dry-run=client -o yaml > file.yaml` 