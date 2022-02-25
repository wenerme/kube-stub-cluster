NAMESPACE := $(shell basename $(shell pwd))
ifneq ("$(wildcard NAMESPACE)","")
	NAMESPACE := $(shell cat NAMESPACE)
endif

build: $(wildcard kustomization.yaml) $(wildcard values.yaml)
	! [ -e build.sh ] || sh ./build.sh
	! [ -e kustomization.yaml ] || kustomize build ./ > build.ignored.yaml
	! [ -e Chart.yaml ] || helm template $$(basename $$PWD) --namespace ${NAMESPACE} ./ > build.ignored.yaml
verify: build
	kubectl -n ${NAMESPACE} apply -f build.ignored.yaml --dry-run=client
verify-server: build
	kubectl -n ${NAMESPACE} apply -f build.ignored.yaml --dry-run=server
apply: build
	kubectl -n ${NAMESPACE} apply -f build.ignored.yaml

up: $(wildcard Chart.yaml) $(wildcard update.sh)
	! [ -e Chart.yaml ] || helm dep up .
	! [ -e update.sh ] || sh ./update.sh

# from ide click to run
up-verify: up verify
up-verify-server: up verify-server
up-build: up build

charts: $(wildcard Chart.yaml)
	! [ -e Chart.yaml ] || helm dep up .

seal:
	mkdir -p templates
	ls *.secret.yaml | xargs -n 1 -I {} sh -c 'kubeseal -f {} -o yaml -n ${NAMESPACE} > templates/$$(echo {}|sed "s/[.]secret[.]/.sealed./")'
	git add templates/*.sealed.yaml

clean:
	rm -rf build.ignored.yaml
	rm -rf charts

kustomize-add-templates:
	kustomize edit add resource templates/*.yaml
