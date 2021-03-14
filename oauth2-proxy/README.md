# oauth2-proxy

一个 OAuth2 Proxy 对应一个 Client，需要不同角色可启动多个 Proxy。 Proxy 在当前 Namespace 易配 Ingress，但也可以映射到其他空间使用。

```yaml
# 原 Ingress 添加 annotation 拦截 auth
kind: Ingress
metdata:
  annotations:
    kubernetes.io/ingress.class: nginx
    # 添加 auth
    nginx.ingress.kubernetes.io/auth-url: "https://$host/oauth2/auth"
    nginx.ingress.kubernetes.io/auth-signin: "https://$host/oauth2/start?rd=$escaped_request_uri"
    # 需要 set-xauthrequest: true
    nginx.ingress.kubernetes.io/auth-response-headers: "x-auth-request-user, x-auth-request-email"
# rest...

---
# 添加处理 auth 的 ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: oauth2-ingress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - backend:
          service:
            name: oauth2-proxy
            port:
              name: http
        # 添加 /oauth2 处理
        path: /oauth2
        pathType: ImplementationSpecific
```

__映射到其他空间使用__

```yaml
kind: Service
apiVersion: v1
metadata:
  name: oauth2-proxy
  namespace: longhorn-system
spec:
  type: ExternalName
  externalName: oauth2-proxy.auth.svc.cluster.local
  ports:
  - port: 80
    name: http
    targetPort: 80
```
