ifneq ("$(wildcard NAMESPACE)","")
	NAMESPACE := $(shell cat NAMESPACE)
endif
ifeq ($(NAMESPACE),)
NAMESPACE := $(shell basename $(shell pwd))
endif

up:
	helm dep up .
build: values.yaml Chart.yaml Chart.lock
	helm template $$(basename $$PWD) --include-crds --namespace ${NAMESPACE} ./ > build.ignored.yaml
verify: build
	kubectl -n ${NAMESPACE} apply -f build.ignored.yaml --dry-run=client

verify-server: build
	kubectl -n ${NAMESPACE} apply -f build.ignored.yaml --dry-run=server

up-verify: up verify
up-verify-server: up verify-server

seal:
	mkdir -p templates
	ls *.secret.yaml | xargs -n 1 -I {} sh -c 'kubeseal -f {} -o yaml -n ${NAMESPACE} > templates/$$(echo {}|sed "s/.secret./.sealed./")'
