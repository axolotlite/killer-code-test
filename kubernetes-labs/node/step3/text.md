## Tasks:  
Ensure that the controlplane is no longer operational:
* Delete the manifests for the static pods in the `kube-system` namespace
* Delete the kubeconfig

Once the static pods and etcd are deleted, this cluster is no longer recoverable.  
Task Well Done!  