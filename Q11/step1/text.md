**CKA Lab 11: Gateway API Migration**

### Tasks

1. **Create a Gateway** named `web-gateway`:

* **Hostname:** `gateway.web.k8s.local`
* Maintain the existing **Ingress TLS configuration** for `web`
* Use existing **GatewayClass:** `cluster-gateway`

2. **Create an HTTPRoute** named `web-route`:

* **Hostname:** `gateway.web.k8s.local`
* Preserve the **routing rules** from the existing Ingress for `web`
