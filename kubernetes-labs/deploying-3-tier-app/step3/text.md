**Resource Requests and Limits**  
This 3 tier app was hosted on a VM, your tasked with creating the needed resources for this application on Kubernetes.  
Finally create a Statefulset for the database:  
* Database
    * Name: `store-db`
    * Image: `postgres:14.23-alpine3.23`
    * Resource Requests: 
      * CPU: `10m`
      * Memory: `200Mi`
    * Resource Requests: 
      * CPU: `60m`
      * Memory: `1000Mi`

**Hint:**  
Use the following command to create a yaml file  
`kubectl create <deployment_name> --image=<image> --dry-run=client -o yaml > file.yaml`   
Then modify the `Kind: Deployment` into `Kind: StatefulSet` and remove the `spen.strategy`  

You can use the documentation:  
- https://kubernetes.io/

keyword:  
* `limits`  

page `Resource Management for Pods and Containers - Kubernetes`  
page keywords:  
* `kind: Pod`  
* `resources:`  