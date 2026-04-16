**CKA Lab 02: ArgoCD Installation with Helm**

### Tasks

1. **Add the official ArgoCD Helm repository** with the name `argocd`

   * **URL:** `https://argoproj.github.io/argo-helm`

2. **Create a namespace** called `argocd`

3. **Generate a Helm template** from the ArgoCD chart with the following specifications:

   * **Chart version:** `9.1.10`
   * **Namespace:** `argocd`
   * **Do not install CRDs**
   * **Save the generated YAML manifest** to `/root/argo-helm.yaml`
**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.