**NetworkPolicy - Pod Label Configuration**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

**NetworkPolicy - Pod Label Configuration**

**Context**
Three Deployments are spread across different namespaces:
- `backend` in namespace `golden-hawk`
- `front` in namespace `frontend`
- `db` in namespace `database`

Two **NetworkPolicies** already exist in the `golden-hawk` namespace. You **cannot create, modify, or delete** any NetworkPolicy. The policies use **cross-namespace selectors** (`namespaceSelector` + `podSelector`), but the namespaces and Pods are missing the labels the policies expect. Your task is to label the **namespaces** and **Deployments** so that `backend` can **only** send and receive traffic to/from `front` and `db`.

**Objectives**

* Inspect existing **NetworkPolicies** to understand their `namespaceSelector` and `podSelector` rules
* Label **namespaces** so `namespaceSelector` matches
* Label **Deployments** so `podSelector` matches
* Understand **cross-namespace** NetworkPolicy rules

You will need to use `kubectl label <resource> <key>=<value>` to label the target resources