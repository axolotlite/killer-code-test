**NetworkPolicy - Pod Label Configuration**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

**NetworkPolicy - Pod Label Configuration**

**Context**
In the `golden-hawk` namespace, there are three Deployments (`front`, `db`, and `backend`) and two pre-existing **NetworkPolicies**. You **cannot create, modify, or delete** any NetworkPolicy. The policies are already configured, but the Pods are missing the labels that the policies select on. Your task is to label the Pods (or their Deployments) so that the `backend` Pod can **only** send and receive traffic to/from `front` and `db`.

**Objectives**

* Inspect existing **NetworkPolicies** to understand their `podSelector` and `ingress`/`egress` rules
* Identify the **labels** required by the policies
* Apply the correct **labels** to Pods or Deployments so the policies take effect

You will need to use `kubectl label <resource> <key>=<value>` to label the target deployment