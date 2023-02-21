REPO_ROOT ?= $(shell git rev-parse --show-toplevel)
-include $(REPO_ROOT)/k8s.mk

info:
build:
seal:

up-verify: up verify
up-verify-server: up verify-server
up-build: up build

delete:

images: build
	grep image: build.ignored.yaml | sort -u | sed -r 's/\s*image:\s*(\S+)/\1/'
