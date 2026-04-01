**CKA Lab 08: CNI Installation**
Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

### CNI & Network Policy

**Context**
You need to install a **CNI plugin** that supports **NetworkPolicies**. You can choose between **Flannel** or **Calico**.

**Objectives**

* Understand **CNI Capabilties**
* Install a CNI using a remote **manifest**
* Verify **NetworkPolicy support**

You can use the documentation:
- https://docs.tigera.io/

keyword:
* `quickstart`
page keywords:
* `step 2`
* `install calico`