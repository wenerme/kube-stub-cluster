# Deploy keydb on K8S

- active-master mode
- if replica > 2 will use multi-master

> **note**
> * Before deploy, you need to prepare the [keydb-secrets.secret.yaml](./keydb-secrets.secret.yaml)
> * Change replicas also need to change the env POD_REPLICAS
