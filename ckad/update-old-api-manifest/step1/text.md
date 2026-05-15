**Step 1 — Update Workload & Policy API Versions**

### Tasks

Fix the deprecated API versions in `~/deploy/workloads.yaml` and deploy the resources to the `garland` namespace.

1. **Update the Deployment** `web`:

   * Change `apiVersion` from `extensions/v1beta1` to `apps/v1`
   * Add the **required** `spec.selector.matchLabels` field matching the pod template labels

2. **Update the DaemonSet** `log-collector`:

   * Change `apiVersion` from `apps/v1beta1` to `apps/v1`
   * Add the **required** `spec.selector.matchLabels` field matching the pod template labels

3. **Update the CronJob** `cleanup`:

   * Change `apiVersion` from `batch/v1beta1` to `batch/v1`

4. **Update the PodDisruptionBudget** `web-pdb`:

   * Change `apiVersion` from `policy/v1beta1` to `policy/v1`

5. **Deploy** all resources from `~/deploy/workloads.yaml` to the `garland` namespace

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.