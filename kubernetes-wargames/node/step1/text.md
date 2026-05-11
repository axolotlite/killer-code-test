## Tasks:  
* You need to write all the available nodes into a file:  
`kubectl get nodes > ~/report/nodes.txt`  
* Find the worker node ip address:  
`kubectl get nodes -o wide`  
* Verify ssh accessibility to the node:  
`ls ~/.ssh`  
`cat /etc/hosts`  
* Access the worker Node:  
`ssh node01`  
* Disable the kubelet:  
`systemctl stop kubelet`  
* Return to the controlplane:  
`exit`  
* Monitor the status of the nodes:  
`kubectl get nodes -w`  

Once you can confirm that the worker node is down  
Delete the controlplane static pods to disable the api and cripple the cluster!  
* Go to `/etc/kubernetes/manifests` directory  
`cd /etc/kubernetes/manifests`  
* Delete all the **Static Manifests**  
`rm *`  
* Ensure that the api is no longer reachable  
`kubectl get nodes`  
* Delete the **kubeconfig**  
`echo $KUBECONFIG`  
`cd ~/.kube`  
`rm config`  
* Check the default api endpoint to confirm kubeconfig deletion  
`kubectl get nodes`  

Finish the lab. 