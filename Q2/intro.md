**CKA Lab 02: ArgoCD Installation with Helm**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

**ArgoCD Installation with Helm**

**Context**
You need to create an Argo CD `template` manifest in aspecific directory using Helm, while ensuring that the CRDs are **not installed**.

**Objectives**

* Add the Helm repository
* Configure Helm chart options using `helm show values <repo>/<chart>
* Use `helm template` to generate manifests using the 