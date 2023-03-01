# appwrite on Kubernetes

- Based on https://appwrite.io/install/compose

## Install

fill all secrets first

```bash
grep -E '\$\(.*?\)' *.secret.yaml
```

change all example

```bash
grep 'example.com' *.yaml
```

ensure extra resource included

```bash
kustomize edit add resource *.yaml
```

review

```base
kustomize build .
```

install

```bash
kustomize build . | kubectl apply -f -
```

---

delete

```bash
kustomize build . | kubectl delete -f -
```

- need to manually delete the hostPath
