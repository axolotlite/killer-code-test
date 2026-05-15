**Step 2 — Update Ingress API Version**

### Tasks

Fix the deprecated Ingress manifest in `~/deploy/ingress.yaml` and deploy it to the `garland` namespace.

1. **Update the Ingress** `web-ingress`:

   * Change `apiVersion` from `extensions/v1beta1` to `networking.k8s.io/v1`
   * Add `pathType: Prefix` to **each** path entry
   * Convert the old backend format:
     ```text
     # Old format
     backend:
       serviceName: web
       servicePort: 80
     ```
     to the new format:
     ```text
     # New format
     backend:
       service:
         name: web
         port:
           number: 80
     ```

2. **Deploy** the Ingress from `~/deploy/ingress.yaml` to the `garland` namespace

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.
