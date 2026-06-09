**Kubernetes Services**  
This 3 tier app pods have been created, however they cannot communicate, you are tasked with creating a service for these applications!  
Edit the backend **Deployment**:  
* ContainerPort: `5000`

Expose the backend **Deployment** through a **Service**:
* Name: `backend-svc`
* Type: `ClusterIP`
* port: `5000`
* targetPort: `5000`

**Hint:**  
Use the following command to create a yaml file  
`kubectl expose deployment <deployment_name> --type <ServiceType> --port <port> --target-port <target port>` 