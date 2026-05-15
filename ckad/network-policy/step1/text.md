**NetworkPolicy - Pod Label Configuration**

### Tasks

You **cannot create, modify, or delete** any NetworkPolicy. You may only **label** Pods or Deployments.

In the `golden-hawk` namespace, configure the environment so that the `backend` Pod can **only** send and receive traffic to/from `front` and `db`.

1. **Inspect the existing NetworkPolicies** in the `golden-hawk` namespace

   * Identify the `podSelector` that selects the restricted Pod
   * Identify the `ingress.from` and `egress.to` selectors that allow traffic from `front` and `db`

2. **Label the `backend` Deployment** so it is selected by the NetworkPolicies

   * Apply the label the `default-deny` and `allow-front-db` policies expect on the restricted Pod

3. **Label the `front` Deployment** so it matches the allow-rule selectors

   * Apply the label that the `allow-front-db` policy references in its `ingress.from` and `egress.to` rules

4. **Label the `db` Deployment** so it matches the allow-rule selectors

   * Apply the label that the `allow-front-db` policy references in its `ingress.from` and `egress.to` rules

**Note:** Label the **Deployment's pod template** (not just the running Pod) so labels persist across restarts.

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.
