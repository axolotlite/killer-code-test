## Intro:  
BREAK THE CLUSTER!!  
Disrubt the kubernetes cluster operation by disabling the `kubelet` on the worker node and confirm that it's status is no longer `Ready`  

## Task:  
From inside the vm, disable the service using:  
* `systemctl`: to `stop` the `kubelet` service on the worker node  
* `exit`: exit the ssh session from the node  
* `kubectl`: to `get` the `nodes` status