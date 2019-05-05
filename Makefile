SHELL=bash

# Use same name as on Docker Hub
REPO	:= codeaster

.PHONY: help build common deps-seq deps-mpi seq mpi clean

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
		-f ./Dockerfile.$(2).$(3) -t codeastersolver/$(1)-$(2) .
endef

help: ## Print Help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: seq mpi ## Build all `code_aster` images

common: ## Build base image for prerequisites
	$(call build_image,$(REPO),$(@),default)

deps-seq: common ## Build base image for prerequisites for `code_aster` sequential
	$(call build_image,$(REPO),$(@),default)

deps-mpi: common ## Build base image for prerequisites for `code_aster` parallel
	$(call build_image,$(REPO),$(@),default)

seq: deps-seq ## Build sequential `code_aster` image
	$(call build_image,$(REPO),$(@),default)

mpi: deps-mpi ## Build parallel `code_aster` image
	$(call build_image,$(REPO),$(@),default)

clean: ## Remove unused docker data
	docker system prune -f

.DEFAULT_GOAL := help
