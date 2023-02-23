# supabase

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
