**CKA Lab 17: TLS Configuration**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

### TLS Configuration

**Context**
An **Nginx deployment** exists with a ConfigMap that supports **TLSv1.2** and **TLSv1.3**. You need to configure it to support **TLSv1.3 only**.

**Objectives**

* Modify the **Nginx ConfigMap** by removing the depricated **TLSV1.2**
* Understand **SSL/TLS configuration**
* Update the `hosts` file
* Restart the deployment to **apply changes**
