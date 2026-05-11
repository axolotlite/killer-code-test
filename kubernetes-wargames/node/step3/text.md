## Tasks:  
Ensure that the controlplane is no longer operational:
* Write the cluster api endpoint url into `~/reports/api-url.txt`
* Delete the manifests for the static pods in the `kube-system` namespace
* Write the default api endpoint into `~/reports/default-api-url.txt`
* Delete the kubeconfig

Once the static pods and etcd are deleted, this cluster is no longer recoverable.  
Task Well Done!  