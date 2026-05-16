**Controlplane Troubleshooting**

### Tasks
The `kube-apiserver` is down due to incorrect etcd configuration
* Diagnose the problem
* Fix the kube-apiserver manifest file
* Ensure that the kubernetes api is reachable

The `kube-controller-manager` and `kube-scheduler` are in **CrashLoop**
- Check the **requests & limits** for these pods
- Check the **controlplane node** resources
- Update the requests of the `kube-controller-manager` and `kube-scheduler` to be **10%** of the node cpu resource
- Update the requests of the `kube-controller-manager` and `kube-scheduler` to be **10%** of the node memory resource

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.
**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.