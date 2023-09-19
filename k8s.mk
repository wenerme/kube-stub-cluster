REPO_ROOT 	?= $(shell git rev-parse --show-toplevel)
#-include $(REPO_ROOT)/mod.mk # copy to dir & uncomment

SHEL := /bin/bash
-include $(wildcard .env.* $(REPO_ROOT)/.env.* .env $(REPO_ROOT)/.env)
export NAMESPACE
export KUBE_CONTEXT

# Module override
-include local.mk

NAMESPACE := $(or $(NAMESPACE), $(shell [ -e ./NAMESPACE ] && cat NAMESPACE))
NAMESPACE := $(or $(NAMESPACE), $(shell basename $(PWD)))

KUBECTL 	?= kubectl
HELM 		?= helm
KUBESEAL 	?= kubeseal

ifneq ("$(wildcard $(REPO_ROOT)/kubeconfig.yaml)","")
export KUBECONFIG="$(REPO_ROOT)/kubeconfig.yaml"
KUBECTL := $(KUBECTL) --kubeconfig $(KUBECONFIG)
HELM := $(HELM) --kubeconfig $(KUBECONFIG)
endif

ifneq ($(NAMESPACE),)
KUBECTL 	:= $(KUBECTL) -n $(NAMESPACE)
HELM 		:= $(HELM) -n $(NAMESPACE)
KUBESEAL 	:= $(KUBESEAL) -n $(NAMESPACE)
endif

ifneq ($(KUBE_CONTEXT),)
KUBECTL 	:= $(KUBECTL) --context $(KUBE_CONTEXT)
HELM 		:= $(HELM) --kube-context $(KUBE_CONTEXT)
KUBESEAL 	:= $(KUBESEAL) --context $(KUBE_CONTEXT)
endif

APP_NAME ?= $(shell basename $(PWD))

# Extra local ignored actions
-include ignored.mk

info: ## show current context - NAMESPACE, CONTEXT
	@echo app: $(APP_NAME)
	@echo context: $(KUBE_CONTEXT)
	@echo namespace: $(NAMESPACE)
	@echo kubectl: $(KUBECTL)
	@echo helm: $(HELM)
	@echo kubeseal: $(KUBESEAL)

.PHONY: ns always
always:

ifneq ("$(wildcard kustomization.yaml)","")

up: ## update
	! [ -e update.sh ] || sh ./update.sh

build: $(wildcard kustomization.yaml) ## build yaml
	@! [ -e build.sh ] || sh ./build.sh
	@! [ -e kustomization.yaml ] || kustomize build ./ > build.ignored.yaml

apply: build ## apply resource
	$(KUBECTL) apply -f build.ignored.yaml

delete: build ## delete resource
	$(KUBECTL) delete -f build.ignored.yaml

kustomize-add-templates: ## add templates to kustomization.yaml
	kustomize edit add resource templates/*.yaml

verify: build  ## client verify
	$(KUBECTL) apply -f build.ignored.yaml --dry-run=client

else ifneq ("$(wildcard Chart.yaml)","")

up:
	$(HELM) dep up .

build:
	@$(HELM) template $(APP_NAME) ./ > build.ignored.yaml

apply:
	$(HELM) upgrade --install $(APP_NAME) ./

verify:
	$(HELM) upgrade --install $(APP_NAME) --verify ./

delete:
	$(HELM) uninstall $(APP_NAME)

endif

verify-server: build ## verify at server side
	$(KUBECTL) apply -f build.ignored.yaml --dry-run=server


# from ide: click to run
up-verify: up verify
up-verify-server: up verify-server
up-build: up build

SEAL_PATTERN ?= ".*"
seal: ## seal all secret to sealed
	@mkdir -p templates
	@ls *.secret.yaml | grep -E "$(SEAL_PATTERN)" | tee -a /dev/fd/2 | xargs -I {} sh -c '$(KUBESEAL) -f {} -o yaml > templates/$$(echo {}|sed "s/[.]secret[.]/.sealed./")'
	@git add templates/*.sealed.yaml

clean: ## Cleanup charts & build
	rm -rf build.ignored.yaml
	rm -rf charts

ns: ## create namespace
	$(KUBECTL) create ns $(NAMESPACE)
ns-delete: ## delete namespace
	$(KUBECTL) delete ns $(NAMESPACE)
ns-ls: ## list namespace
	$(KUBECTL) get ns

ingress-ls: ## list ingress
	$(KUBECTL) get ingress -A
ingress-ls-domain: ## list ingress with domain
	$(KUBECTL) get ingress -A -o json | jq -r '.items[] | [.metadata.name, .spec.rules[].host] | @tsv' | sort

svc-ls: ## list service
	$(KUBECTL) get svc -A

svc-ls-nodeport: ## list service with nodeport
	$(KUBECTL) get svc -A -o json | jq -r '.items[] | select(.spec.type == "NodePort") | [.metadata.name, .spec.ports[].nodePort] | @tsv' | sort

images: build ## show images
	@grep image: build.ignored.yaml | sort -u | sed -r 's/\s*image:\s*(\S+)/\1/' | tr -d '"' | sort

images-prefetch:
	@echo '{"apiVersion":"apps/v1","kind":"DaemonSet","metadata":{"name":"prefetch","namespace":"default","labels":{"app":"prefetch"}},"spec":{"selector":{"matchLabels":{"app":"prefetch"}},"template":{"metadata":{"labels":{"app":"prefetch"}},"spec":{"containers":[]}}}}' > prefetch.ds.ignored.yaml
	@$(MAKE) images | xargs -I IMG yq '.spec.template.spec.containers += { "name": "c"+(.spec.template.spec.containers|length), "image": "IMG", "imagePullPolicy": "IfNotPresent", "command": [ "tail", "-f", "/dev/null" ] }' -i prefetch.ds.ignored.yaml
	@yq -P -I2 -i prefetch.ds.ignored.yaml
	$(KUBECTL) apply -f prefetch.ds.ignored.yaml --namespace=default

nodes: ## show nodes in cluster for verify config
	$(KUBECTL) get nodes

storage\:class: ## show storage class in cluster for verify config
	$(KUBECTL) get storageclass

events: ## show events in cluster
	$(KUBECTL) get events -Aw

fix: ## fix some common issue
	! [ -e "$(REPO_ROOT)/kubeconfig.yaml" ] || chmod 600 "$(REPO_ROOT)/kubeconfig.yaml"

update\:k8s.mk: ## update k8s.mk
	@curl -s https://ghproxy.com/raw.githubusercontent.com/wenerme/kube-stub-cluster/main/k8s.mk > $(REPO_ROOT)/k8s.mk

help: ## Show this help
	@grep -E -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# %: %-default
