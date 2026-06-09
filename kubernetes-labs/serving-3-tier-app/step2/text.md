**Kubernetes Services**  
This 3 tier app pods have been created, however they cannot communicate, you are tasked with creating a service for these applications!  
Edit the Database **StatefulSet**:  
* ContainerPort: `5432`

Expose the backend **Deployment** through a **Service**:
* Name: `database-svc`
* Type: `ClusterIP`
* port: `5432`
* targetPort: `5432`

**Hint:**  
Use the following command to create a yaml file  
`kubectl create svc clusterip <service-name> --tcp <port>:<target-port>`   
Next define the selector for the service  
`kubectl set selector svc <service-name> <key>=<value>`