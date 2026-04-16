**CKA Lab 06: Custom Resource Definitions (CRDs)**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

**Custom Resource Definitions (CRDs)**

**Context**
`cert-manager` is installed in your cluster. You need to explore its **CRDs** and extract documentation.

**Objectives**

* List the **CRDs** of an operator using `kubectl get crds`
* Use `kubectl explain` on **Custom Resources** through `kubectl explain <crd>.spec.<object>`
* Understand the **structure of CRDs**
