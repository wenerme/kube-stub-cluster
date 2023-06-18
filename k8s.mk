REPO_ROOT 	?= $(shell git rev-parse --show-toplevel)
#-include $(REPO_ROOT)/mod.mk # copy to dir & uncomment

SHEL := /bin/bash
-include $(wildcard .env.* $(REPO_ROOT)/.env.* .env $(REPO_ROOT)/.env)
export NAMESPACE
export KUBE_CONTEXT

# Module override
-include local.mk

NAMESPACE := $(or $(NAMESPACE), $(shell [ -e ./NAMESPACE ] && cat NAMESPACE))
NAMESPACE := $(or $(NAMESPACE), $(shell basename $(shell pwd)))

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
	! [ -e build.sh ] || sh ./build.sh
	! [ -e kustomization.yaml ] || kustomize build ./ > build.ignored.yaml

apply: build ## apply resource
	$(KUBECTL) apply -f build.ignored.yaml

delete: build ## delete resource
	$(KUBECTL) delete -f build.ignored.yaml

else ifneq ("$(wildcard values.yaml)","")

up:
	$(HELM) dep up .

build:
	$(HELM) template $(APP_NAME) ./ > build.ignored.yaml

apply:
	$(HELM) upgrade --install $(APP_NAME) ./

delete:
	$(HELM) uninstall $(APP_NAME)


endif

verify: build  ## client verify
	$(KUBECTL) apply -f build.ignored.yaml --dry-run=client
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

kustomize-add-templates:
	kustomize edit add resource templates/*.yaml

clean: ## Cleanup charts & build
	rm -rf build.ignored.yaml
	rm -rf charts

ns: ## create namespace
	$(KUBECTL) create ns $(NAMESPACE)
ns\:delete:
	$(KUBECTL) delete ns $(NAMESPACE)
ns\:ls:
	$(KUBECTL) get ns

images: build
	grep image: build.ignored.yaml | sort -u | sed -r 's/\s*image:\s*(\S+)/\1/'

nodes: ## show nodes in cluster for verify config
	$(KUBECTL) get nodes

events: ## show events in cluster
	$(KUBECTL) get events -Aw

help: ## Show this help
	@grep -E -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

%: %-default
