**Step 3 — Remove PodSecurityPolicy & Deploy RBAC**

### Tasks

Fix the manifest in `~/deploy/rbac-psp.yaml` and deploy the valid resources to the cluster.

1. **Remove the PodSecurityPolicy** `restricted-psp` from the manifest

   * `PodSecurityPolicy` (`policy/v1beta1`) was **removed in Kubernetes v1.25** and cannot be deployed

2. **Verify the RBAC resources** are already using the correct API version:

   * `ClusterRole` and `ClusterRoleBinding` should use `rbac.authorization.k8s.io/v1`

3. **Deploy** the remaining valid resources from `~/deploy/rbac-psp.yaml`

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.
