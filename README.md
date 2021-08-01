# Kubernetes 集群部署模板

方便学习参考和粘贴复制的集群部署模板。

## Why

* 尽量的复用部署过的项目校验
* 尽量的复用写过的 charts 和 values
* 快速开始使用

## 特点

* 使用国内容器镜像 - 部署快稳定
  * 镜像来源于 - [wenerme/container-mirror](https://github.com/wenerme/container-mirror)
  * 预先拉好的镜像而不是按需拉
* 使用国内 Charts - 方便使用,稳定,快
  * Charts 来源 - [wenerme/charts](https://github.com/wenerme/charts)
  * 收集了所需应用的官方 chart 并通过国内 CDN 提供
* ArgoCD 驱动部署
* 应用通过 helm + kustomize 部署

> 部分 docker.io 镜像尚未映射

## 如何修改为自行使用

* 粘贴复制 stub-cluster 为 `<你的名字>-cluster`
* 项目内搜索 example.com 修改为你的域名
* 项目内搜索 stub - 按需修改

## 部署步骤

1. /argocd

* 首先部署 argocd - 其他内容通过 ArgoCD 来部署
* `make apply`

2. /stub-cluster/stub-cluster

* 配置 git 仓库
* 部署 argocd 的 stub-cluster 应用 - 部署 stub-cluster

3. 其他内容将按照 stub-cluster 定义的进行部署

## 部署技巧

* 大部分应用下包含 Makefile
  * 包含升级、验证 等 - 可直接在命令行或者 IDE 操作

```bash
# 代理集群网络 - 假设集群是 10.10
sshuttle -r kube-m1 10.10.0.0/16

# 转发 argocd 到本地观察状态
kubectl -n argocd port-forward svc/argocd-server 8443:https

# ArgoCD
# 账号 admin
# 密码
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2 | pbcopy

# 部署时观察集群状态
kubectl get events -w --all-namespaces
```

## Release Watch

- ![](https://img.shields.io/github/v/release/keycloak/keycloak?label=Keycloak)
- ![](https://img.shields.io/github/v/release/oauth2-proxy/oauth2-proxy?label=oauth2-proxy)
