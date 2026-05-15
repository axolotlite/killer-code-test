**Migrate Environment Variables to Secrets**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

**Migrate Environment Variables to Secrets**

**Context**
A Deployment named `webapp` exists in the `production` namespace with hardcoded database credentials in its environment variables. You need to migrate these credentials into a Kubernetes **Secret** and update the Deployment to reference them.

**Objectives**

* Create a **Secret** with multiple key-value pairs
* Modify a **Deployment** to use `secretKeyRef` for environment variables
* Understand the relationship between **Secrets** and **Pod specs**

You can use the documentation:
- https://kubernetes.io/

keywords:
* `Secret key ref`

Page `Distribute Credentials Securely Using Secrets - Kubernetes`
page keywords:
* `kind: pod`
* `secretKeyRef`