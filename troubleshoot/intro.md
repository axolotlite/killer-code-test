## Troubleshooting Kubernetes API Server (ETCD Connection)
The scenario is as follows, after a cluster migration, this controlplane's kube-api server is not coming up.

Previously the etcd server was external, after the migration the etcd server has been moved to the kubernetes controlplane.  
Currently the kube-api server is pointing to the port 2380

There is a deployment in the default namespace, check that it's working correctly.