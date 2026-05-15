**NetworkPolicy - Pod Label Configuration**

### Tasks

You **cannot create, modify, or delete** any NetworkPolicy. You may only **label** Pods or Deployments.

You will find a copy of the Network Policy manifests at `~/network-policies/`, these are provided for you to read, DO NOT APPLY or CHANGE them.

You can find a copy of the deployments at `~/deployments` you can update and deploy them.  

The Deployments are in separate namespaces:
* `backend` → namespace `golden-hawk`
* `front` → namespace `frontend`
* `db` → namespace `database`

Configure the environment so that `backend` can **only** send and receive traffic to/from `front` and `db`.

1. **Inspect the existing NetworkPolicies** in the `golden-hawk` namespace

   * Identify the `podSelector` that selects the restricted Pod
   * Identify the `namespaceSelector` and `podSelector` used in `ingress.from` and `egress.to`

2. **Label the `backend` Deployment** (in `golden-hawk`) so it is selected by the NetworkPolicies

   * Apply the label the `default-deny` and `allow-front-db` policies expect on the restricted Pod

3. **Label the `front` Deployment** (in `frontend`) so it matches the `podSelector` in the allow-rules

4. **Label the `db` Deployment** (in `database`) so it matches the `podSelector` in the allow-rules

**Note:** Label the **Deployment's pod template** (not just the running Pod) so pod labels persist across restarts.

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.
