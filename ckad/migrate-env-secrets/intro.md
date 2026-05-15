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
- https://kubernetes.io/docs/concepts/configuration/secret/

keywords:
* `Secrets`
* `Using Secrets as environment variables`

Page `Distribute Credentials Securely Using Secrets`
page keywords:
* `Create a Secret`
* `secretKeyRef`

Page `Managing Secrets using kubectl`
page keywords:
* `kubectl create secret generic`