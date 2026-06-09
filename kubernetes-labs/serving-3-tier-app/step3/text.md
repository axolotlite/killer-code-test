**Kubernetes Services**  
This 3 tier app pods have been created, however they cannot communicate, you are tasked with creating a service for these applications!  
Edit the Frontend **Deployment**:  
* ContainerPort: `8080`

Expose the backend **Deployment** through a **Service**:
* Name: `frontend-svc`
* Type: `NodePort`
* port: `8080`
* NodePort: `31080`  
* 
**Hint:**  
Use the following command to create a yaml file  
`kubectl expose Deployment <deployment_name> --type <ServiceType> --port <port> --target-port <target port>`  
Next Edit the Service to change it's parameters.  