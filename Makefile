SHELL=bash

# Set Environment Variables
IMG	:= code_aster

.PHONY: help build common seq mpi clean

define source_env
	for file in env.d/*; do \
		echo "loading environment from $${file}" ; \
		source $${file}; \
	done
endef

define build_image
	@echo "building $(1)_$(2):$(3)..." ; \
	$(call source_env) ; \
	docker build \
		--build-arg https_proxy=$${https_proxy} \
		--build-arg http_proxy=$${http_proxy} \
		--build-arg no_proxy=$${no_proxy} \
		-f ./Dockerfile.$(2).$(3) -t $(1)_$(2):$(3) .
endef

help: ## Print Help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: seq mpi ## Build all `code_aster` images

common: ## Build base image for `code_aster` sequential & parallel
	$(call build_image,$(IMG),$(@),default)

seq: common ## Build sequential `code_aster` image
	$(call build_image,$(IMG),$(@),default)

mpi: common ## Build parallel `code_aster` image
	$(call build_image,$(IMG),$(@),default)

clean: ## Remove unused docker data
	docker system prune -f

distclean: clean ## Remove unused docker data and intermediate images
	docker image rm $(IMG)_common:default

.DEFAULT_GOAL := help
