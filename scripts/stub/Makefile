REPO_ROOT ?= $(shell git rev-parse --show-toplevel)

-include local.Makefile

NAMESPACE := $(or $(NAMESPACE), $(shell [ -e ./NAMESPACE ] && cat NAMESPACE))
NAMESPACE := $(or $(NAMESPACE), $(shell basename $(shell pwd)))

KUBECTL 	?= kubectl
HELM 		?= helm
KUBESEAL 	?= kubeseal

-include $(REPO_ROOT)/defaults.Makefile

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


build: $(wildcard kustomization.yaml) $(wildcard values.yaml) ## build yaml
	! [ -e build.sh ] || sh ./build.sh
	! [ -e kustomization.yaml ] || kustomize build ./ > build.ignored.yaml
	! [ -e Chart.yaml ] || $(HELM) template $$(basename $$PWD) ./ > build.ignored.yaml
verify: build  ## client verify
	$(KUBECTL) apply -f build.ignored.yaml --dry-run=client
verify-server: build ## verify at server side
	$(KUBECTL) apply -f build.ignored.yaml --dry-run=server
apply: build ## apply resource
	$(KUBECTL) apply -f build.ignored.yaml

up: $(wildcard Chart.yaml) $(wildcard update.sh) ## update
	! [ -e Chart.yaml ] || helm dep up .
	! [ -e update.sh ] || sh ./update.sh

# from ide: click to run
up-verify: up verify
up-verify-server: up verify-server
up-build: up build


seal: ## seal all secret to sealed
	mkdir -p templates
	ls *.secret.yaml | xargs -n 1 -I {} sh -c '$(KUBESEAL) -f {} -o yaml > templates/$$(echo {}|sed "s/[.]secret[.]/.sealed./")'
	git add templates/*.sealed.yaml

kustomize-add-templates:
	kustomize edit add resource templates/*.yaml

delete: build ## delete resource
	$(KUBECTL) delete -f build.ignored.yaml

clean: ## Cleanup charts & build
	rm -rf build.ignored.yaml
	rm -rf charts


nodes: ## show nodes in cluster for verify config
	$(KUBECTL) get nodes
show-context: ## show current context - NAMESPACE, CONTEXT
	@echo context: $(KUBE_CONTEXT)
	@echo namespace: $(NAMESPACE)
	@echo kubectl: $(KUBECTL)
	@echo helm: $(HELM)
	@echo kubeseal: $(KUBESEAL)

help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
