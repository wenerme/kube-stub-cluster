REPO_ROOT ?= $(shell git rev-parse --show-toplevel)
-include $(REPO_ROOT)/k8s.mk


# https://appwrite.io/install/compose

delete:
	$(KUBECTL) -n data-system  delete -l 'app=appwrite' all
