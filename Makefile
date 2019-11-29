SHELL=bash

# Use same name as on Docker Hub
IMG	:= codeaster

SINGULARITY := $(shell which singularity)

# Address of the local repository
LOCALREPO := localhost:5000

.PHONY: help build common seq mpi simg-seq simg-mpi simg simg-local bld_local clean

define source_env
	for file in env.d/*; do \
		echo "loading environment from $${file}" ; \
		source $${file}; \
	done
endef

define build_simg
	@echo "building singularity image $(1)-$(2) ($(3))..." ; \
	[ ! -e images ] && mkdir -p images ; \
	$(call source_env) ; \
	[ ! -z "$(4)" ] && export SINGULARITY_NOHTTPS=1 ; \
	sudo -E $(SINGULARITY) build images/$(1)-$(2)$(5)-$$(cat id.$(3)).simg $(4)Singularity.$(2).$(3)
endef

define push_local
	docker image tag codeastersolver/$(1)-$(2)$(4):$$(cat id.$(3)) \
					 $(LOCALREPO)/codeastersolver/$(1)-$(2)$(4):$$(cat id.$(3)) ; \
	docker push $(LOCALREPO)/codeastersolver/$(1)-$(2)$(4):$$(cat id.$(3))
endef

define build_localdef
	@sed -e 's%From: codeastersolver%From: $(LOCALREPO)/codeastersolver%g' \
		 -e "s%latest%$$(cat id.$(2))%g" \
		Singularity.$(1).$(2) > .local/Singularity.$(1).$(2)
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

build: seq mpi ## Build all `code_aster` images

simg: simg-seq simg-mpi ## Build all `code_aster` singularity images

common: ## Build base image for prerequisites
	@echo "building docker image from Dockerfile.common.default" ; \
	$(call source_env) ; \
	docker build \
		--build-arg https_proxy=$${https_proxy} \
		--build-arg http_proxy=$${http_proxy} \
		--build-arg no_proxy=$${no_proxy} \
		-f ./Dockerfile.common.default -t codeastersolver/codeaster-common:latest . ; \
	docker image tag codeastersolver/codeaster-common:latest \
	                 codeastersolver/codeaster-common:$$(cat id.common)

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

simg-common: common ## Build Singularity image for prerequisites
	$(call build_simg,$(IMG),common,default)

simg-seq: seq ## Build Singularity image for sequential version of `code_aster`
	$(call build_simg,$(IMG),seq,default)

simg-mpi: mpi ## Build Singularity image for parallel version of `code_aster`
	$(call build_simg,$(IMG),mpi,default)

simg-mpixx: mpixx ## Build Singularity image for parallel version of `code_aster`
	$(call build_simg,$(IMG),mpi,asterxx)


bld_local:
	$(call build_localdef,common,default)
	$(call build_localdef,seq,default)
	$(call build_localdef,mpi,default)
	$(call build_localdef,mpi,asterxx)

simg-local: bld_local ## Build Singularity images from the local Docker repository.
	$(call push_local,$(IMG),common,default)
	$(call build_simg,$(IMG),common,default,.local/)
	$(call push_local,$(IMG),seq,default)
	$(call build_simg,$(IMG),seq,default,.local/)
	$(call push_local,$(IMG),mpi,default)
	$(call build_simg,$(IMG),mpi,default,.local/)
	$(call push_local,$(IMG),mpi,asterxx,-asterxx)
	$(call build_simg,$(IMG),mpi,asterxx,.local/,-asterxx)

.DEFAULT_GOAL := help
