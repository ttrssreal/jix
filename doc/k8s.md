## Creating an ingress

#### docs:
 - https://cert-manager.io/docs/usage/ingress/
 - https://kubernetes.io/docs/concepts/services-networking/ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: <name>
  namespace: <namespace>
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-production

    ## differs per backend
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"

    ## internal services should be mtls
    # mtls
    nginx.ingress.kubernetes.io/auth-tls-pass-certificate-to-upstream: "true"
    nginx.ingress.kubernetes.io/auth-tls-verify-client: "on"
    nginx.ingress.kubernetes.io/auth-tls-verify-depth: "1"
    # FIXME: part of declarative secret management
    nginx.ingress.kubernetes.io/auth-tls-secret: default/ca-secret
spec:
  ingressClassName: nginx
  rules:
      ## internal services should of the form name.k8s.jessie.cafe
    - host: <change>.<k8s.>jessie.cafe
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: <service name>
                port:
                  name: <port name>
  tls:
    - hosts:
      - <matches spec.rules[0].host>
      secretName: <store the certificate in this secret>
```
