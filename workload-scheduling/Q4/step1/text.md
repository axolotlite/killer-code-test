**Resource Allocation**

### Tasks

1. **Scale down** the WordPress deployment to 0 replicas

2. **Edit the deployment** to allocate node resources evenly among the 3 pods:  
    * Assign equal **CPU and memory** to each pod.
    * Leave a **safety margin** to avoid node instability.
    * Ensure **init containers** and main containers have the **same requests and limits**.

3. **Scale up** the deployment back to 3 replicas

You can find the WordPress Deployment manifest at `~/deployment.yaml`
**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.