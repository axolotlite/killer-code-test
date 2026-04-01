**CKA Lab 09: cri-dockerd Installation**
Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

### cri-dockerd Installation

**Context**
You need to install **cri-dockerd** to use **Docker** as the container runtime within this Kubernetes cluster.
You will need to do this on the `controlplane`

**Objectives**

* Install a **Debian package**
* Configure and start a **systemd service**
* Configure **sysctl parameters** required by Kubernetes
