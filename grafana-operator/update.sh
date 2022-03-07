set -ex
curl -sfL --remote-name-all https://github.com/grafana-operator/grafana-operator/raw/master/deploy/manifests/latest/{crds.yaml,deployment.yaml,rbac.yaml}
