SHELL=bash

# Use same name as on Docker Hub
IMG	:= codeaster

SINGULARITY := $(shell which singularity)

.PHONY: help build common deps-seq deps-mpi seq mpi simg-seq simg-mpi simg clean

define source_env
	for file in env.d/*; do \
		echo "loading environment from $${file}" ; \
		source $${file}; \
	done
endef

define build_image
	@echo "building docker image $(1)-$(2) ($(3))..." ; \
	$(call source_env) ; \
	docker build \
		--build-arg https_proxy=$${https_proxy} \
		--build-arg http_proxy=$${http_proxy} \
		--build-arg no_proxy=$${no_proxy} \
		-f ./Dockerfile.$(2).$(3) -t codeastersolver/$(1)-$(2) .
endef

define build_simg
	@echo "building singularity image $(1)-$(2) ($(3))..." ; \
	[ ! -e images ] && mkdir -p images ; \
	$(call source_env) ; \
	sudo -E $(SINGULARITY) build images/$(1)-$(2)-$(3).simg Singularity.$(2).$(3)
endef

help: ## Print Help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: seq mpi ## Build all `code_aster` images

simg: simg-seq simg-mpi ## Build all `code_aster` singularity images

common: ## Build base image for prerequisites
	$(call build_image,$(IMG),$(@),default)

deps-seq: common ## Build base image for prerequisites for `code_aster` sequential
	$(call build_image,$(IMG),$(@),default)

deps-mpi: common ## Build base image for prerequisites for `code_aster` parallel
	$(call build_image,$(IMG),$(@),default)

seq: deps-seq ## Build sequential `code_aster` image
	$(call build_image,$(IMG),$(@),default)

mpi: deps-mpi ## Build parallel `code_aster` image
	$(call build_image,$(IMG),$(@),default)

clean: ## Remove unused docker data
	docker system prune -f

simg-seq: seq ## Build Singularity image for sequential version of `code_aster`
	$(call build_simg,$(IMG),seq,default)

simg-mpi: mpi ## Build Singularity image for parallel version of `code_aster`
	$(call build_simg,$(IMG),mpi,default)

.DEFAULT_GOAL := help
