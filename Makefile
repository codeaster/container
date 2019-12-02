SHELL=bash

# Use same name as on Docker Hub
IMG	:= codeaster

SINGULARITY := $(shell which singularity)

VPREREQ := $(shell cat id.common)
VDEFAULT := $(shell cat id.default)

.PHONY: help tag common seq mpi clean salome_meca_dev

define source_env
	for file in env.d/*; do \
		echo "loading environment from $${file}" ; \
		source $${file}; \
	done
endef

help: ## Print Help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

tag: ## Update identifier file (use local source repositories)
	@hg -R ${HOME}/dev/codeaster/src log \
		--rev 'last(tag() and branch(default))' \
		--template '{tags}' > id.default ; \
	hg -R ${HOME}/dev/codeaster-xx/src log \
		--rev 'last(tag() and branch(default) and ancestors(asterxx))' \
		--template '{tags}' > id.asterxx

common: ## Build base image for prerequisites
	@echo "building docker image from Dockerfile.common.default" ; \
	$(call source_env) ; \
	docker build \
		--build-arg https_proxy=$${https_proxy} \
		--build-arg http_proxy=$${http_proxy} \
		--build-arg no_proxy=$${no_proxy} \
		-f ./Dockerfile.common.default -t codeastersolver/codeaster-common:latest . ; \
	docker image tag codeastersolver/codeaster-common:latest \
	                 codeastersolver/codeaster-common:$(VPREREQ)

seq: common ## Build sequential `code_aster` image
	@echo "building docker image from Dockerfile.seq.default" ; \
	$(call source_env) ; \
	docker build \
		--build-arg https_proxy=$${https_proxy} \
		--build-arg http_proxy=$${http_proxy} \
		--build-arg no_proxy=$${no_proxy} \
		-f ./Dockerfile.seq.default -t codeastersolver/codeaster-seq:latest . ; \
	docker image tag codeastersolver/codeaster-seq:latest \
	                 codeastersolver/codeaster-seq:$$(cat id.default)

mpi: common ## Build parallel `code_aster` image
	@echo "building docker image from Dockerfile.mpi.default" ; \
	$(call source_env) ; \
	docker build \
		--build-arg https_proxy=$${https_proxy} \
		--build-arg http_proxy=$${http_proxy} \
		--build-arg no_proxy=$${no_proxy} \
		-f ./Dockerfile.mpi.default -t codeastersolver/codeaster-mpi:latest . ; \
	docker image tag codeastersolver/codeaster-mpi:latest \
	                 codeastersolver/codeaster-mpi:$$(cat id.default)

mpixx: common ## Build parallel `code_aster` image, branch `asterxx`
	@echo "building docker image from Dockerfile.mpi.asterxx" ; \
	$(call source_env) ; \
	docker build \
		--build-arg https_proxy=$${https_proxy} \
		--build-arg http_proxy=$${http_proxy} \
		--build-arg no_proxy=$${no_proxy} \
		-f ./Dockerfile.mpi.asterxx -t codeastersolver/codeaster-mpixx:latest . ; \
	docker image tag codeastersolver/codeaster-mpi-asterxx:latest \
	                 codeastersolver/codeaster-mpi-asterxx:$$(cat id.asterxx)

clean: ## Remove unused docker data
	docker system prune -f

codeaster-common-$(VPREREQ).sif: ## Build Singularity image for prerequisites
	@echo "building singularity image from Singularity.common.default" ; \
	$(call source_env) ; \
	sudo -E $(SINGULARITY) build ${@} Singularity.common.default

codeaster-seq-$(VDEFAULT).sif: codeaster-common-$(VPREREQ).sif ## Build Singularity image for sequential version of `code_aster`
	sudo -E $(SINGULARITY) build ${@} Singularity.seq.default

salome_meca-2019.0.1-2-LGPL.run:
	@echo "dowloading archive from code-aster.org..."

salome_meca_dev: ## Build salome_meca univ + code_aster dev
	@echo "building docker image from Dockerfile.salome_meca.dev" ; \
	$(call source_env) ; \
	docker build \
		--build-arg https_proxy=$${https_proxy} \
		--build-arg http_proxy=$${http_proxy} \
		--build-arg no_proxy=$${no_proxy} \
		-f ./Dockerfile.salome_meca.dev -t salome_meca_dev:latest . ; \
	docker image tag salome_meca_dev:latest \
	                 salome_meca_dev:$$(cat id.salome_meca)


.DEFAULT_GOAL := help
