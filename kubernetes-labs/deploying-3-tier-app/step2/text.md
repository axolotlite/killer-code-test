**Resource Requests and Limits**  
This 3 tier app was hosted on a VM, your tasked with creating the needed resources for this application on Kubernetes.   
Create a **Deployment** for the frontend:  
* frontend application
    * Name: `store-frontend`
    * Image: `ghcr.io/axolotlite/killer-code-test/managed-app/dummy-store-backend`
    * Resource Requests: 
      * CPU: `10m`
      * Memory: `50Mi`
    * Resource Requests: 
      * CPU: `40m`
      * Memory: `500Mi`

**Hint:**  
Use the following command to create a yaml file  
`kubectl create <deployment_name> --image=<image> --dry-run=client -o yaml > file.yaml` 

You can use the documentation:  
- https://kubernetes.io/

keyword:  
* `limits`  

page `Resource Management for Pods and Containers - Kubernetes`  
page keywords:  
* `kind: Pod`  
* `resources:`  