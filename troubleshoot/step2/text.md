## Tasks
The `kube-controller-manager` and `kube-scheduler` are not running, due to the requested resources exceeding the limits of the node
- Check the requests for both static pods at `/etc/kubernetes/manifests/`
- Check the `controlplane` node resources
- Update the requests of the `kube-controller-manager` and `kube-scheduler` to be 10% of the node `cpu` resource