**Gateway API Migration**

### Tasks

1. **Create a Gateway** named `web-gateway` in the `web-app` namespace:
    * **Hostname:** `gateway.web.k8s.local`
    * Maintain the existing **Ingress TLS configuration** for `web`
    * Use existing **GatewayClass:** `cluster-gateway`
2. **Create an HTTPRoute** named `web-route`:
    * **Hostname:** `gateway.web.k8s.local`
    * Preserve the **routing rules** from the existing Ingress for `web`
3. **Delete the ingress** after you're done.

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.