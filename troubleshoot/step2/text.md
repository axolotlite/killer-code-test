## Tasks
The kube-controller-manager is not running, due to the requested resources exceeding the limits of the node
- Check the requests `/etc/kubernetes/manifests/kube-controller-manager.yaml`
- Check the `controlplane` node resources
- Update the requests of the `kube-controller-manager` to be 10% of the node `cpu` resource