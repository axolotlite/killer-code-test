**Update Deprecated API Manifests**

Start by ssh-ing into the controlplane node:
```
ssh controlplane
```{{copy}}

**Update Deprecated API Manifests**

**Context**
You have been given a set of Kubernetes manifests in `~/deploy/` that were written for an older Kubernetes version (v1.15 era). The cluster is running **v1.29+**, and many of the API versions used in these manifests have been **removed or deprecated**. You must update and deploy them.

**Objectives**

* Update **Deployment**, **DaemonSet**, **CronJob**, and **PodDisruptionBudget** to their current `apiVersion`
* Migrate an **Ingress** from `extensions/v1beta1` to `networking.k8s.io/v1`
* Remove **PodSecurityPolicy** resources (removed in v1.25+)
* Deploy all corrected manifests to the `garland` namespace

You can use the `kubectl apply -f <dir> --dry-run=server` to find faulty manifests.  
Then use `kubectl explain <resource>` to find the correct api and fix the manifest.  