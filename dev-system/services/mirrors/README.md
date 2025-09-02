# 镜像

- 常见仓库镜像
- 建议 dockercr 在外部做，因为 k8s/k3s bootstrap 需要用
- 区分 Docker Registry 和 Docker Registry Mirror
  - Docker Registry 不配置 Remote 是允许 Push 的

---

- 主机 dockercr 作为 bootstrap
  - 在 hosts 添加 dockercr
  - 或者直接替换为本地 IP
- 如果用到了 docker 记得修改 /etc/docker/daemon.json

**/etc/rancher/k3s/registries.yaml**

```yaml
mirrors:
  docker.io:
    endpoint:
    - http://dockercr:5000
    - https://dockercr.example.com
    - https://docker.m.daocloud.io
    - https://registry-1.docker.io
  ghcr.io:
    endpoint:
    - https://ghcr.example.com
    - https://ghcr.io
  registry.k8s.io:
    endpoint:
    - https://k8scr.example.com
    - https://registry.k8s.io
  gcr.io:
    endpoint:
    - https://gcr.example.com
    - https://gcr.m.daocloud.io
    - https://gcr.io
  quay.io:
    endpoint:
    - https://quaycr.example.com
    - https://quay.m.daocloud.io
    - https://quay.io
configs:
  "dockercr:5000":
```
