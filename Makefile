###############################
# Common defaults/definitions #
###############################

comma := ,

# Checks two given strings for equality.
eq = $(if $(or $(1),$(2)),$(and $(findstring $(1),$(2)),\
                                $(findstring $(2),$(1))),1)




######################
# Project parameters #
######################

IMAGE_VER ?= $(strip \
	$(shell grep 'ARG image_ver=' Dockerfile | cut -d '=' -f2))
ANSIBLE_VER ?= $(strip \
	$(shell grep 'ARG ansible_ver=' Dockerfile | cut -d '=' -f2))
BIOME_VER ?= $(strip \
	$(shell grep 'ARG biome_ver=' Dockerfile | cut -d '=' -f2))
BUTANE_VER ?= $(strip \
	$(shell grep 'ARG butane_ver=' Dockerfile | cut -d '=' -f2))
DENO_VER ?= $(strip \
	$(shell grep 'ARG deno_ver=' Dockerfile | cut -d '=' -f2))
DOCTL_VER ?= $(strip \
	$(shell grep 'ARG doctl_ver=' Dockerfile | cut -d '=' -f2))
HCLOUD_VER ?= $(strip \
	$(shell grep 'ARG hcloud_ver=' Dockerfile | cut -d '=' -f2))
HELM_VER ?= $(strip \
	$(shell grep 'ARG helm_ver=' Dockerfile | cut -d '=' -f2))
JSONNET_VER ?= $(strip \
	$(shell grep 'ARG jsonnet_ver=' Dockerfile | cut -d '=' -f2))
JSONNET_BUNDLER_VER ?= $(strip \
	$(shell grep 'ARG jsonnet_bundler_ver=' Dockerfile | cut -d '=' -f2))
KUBECTL_VER ?= $(strip \
	$(shell grep 'ARG kubectl_ver=' Dockerfile | cut -d '=' -f2))
PYTHON_VER ?= $(strip \
	$(shell grep 'ARG python_ver=' Dockerfile | cut -d '=' -f2))
TERRAFORM_VER ?= $(strip \
	$(shell grep 'ARG terraform_ver=' Dockerfile | cut -d '=' -f2))

NAME := toolchain
OWNER := $(or $(GITHUB_REPOSITORY_OWNER),instrumentisto)
REGISTRIES := $(strip $(subst $(comma), ,\
	$(shell grep -m1 'registry: \["' .github/workflows/ci.yml \
	        | cut -d':' -f2 | tr -d '"][')))
TAGS ?= $(IMAGE_VER) \
        $(strip $(shell echo $(IMAGE_VER) | cut -d '.' -f1,2)) \
        $(strip $(shell echo $(IMAGE_VER) | cut -d '.' -f1)) \
        latest
VERSION ?= $(word 1,$(subst $(comma), ,$(TAGS)))




###########
# Aliases #
###########

fmt: biome.fmt

image: docker.image

push: docker.push

release: git.release

tags: docker.tags

test: test.docker




###################
# Docker commands #
###################

docker-registries = $(strip \
	$(or $(subst $(comma), ,$(registries)),$(REGISTRIES)))
docker-tags = $(strip $(or $(subst $(comma), ,$(tags)),$(TAGS)))


# Build Docker image with the given tag.
#
# Usage:
#	make docker.image [tag=($(VERSION)|<docker-tag>)] [no-cache=(no|yes)]
#	                  [IMAGE_VER=<image-version>]
#	                  [ANSIBLE_VER=<ansible-version>]
#	                  [BIOME_VER=<biome-version>]
#	                  [BUTANE_VER=<butane-version>]
#	                  [DENO_VER=<deno-version>]
#	                  [DOCTL_VER=<doctl-version>]
#	                  [HCLOUD_VER=<hcloud-version>]
#	                  [HELM_VER=<helm-version>]
#	                  [JSONNET_VER=<jsonnet-version>]
#	                  [JSONNET_BUNDLER_VER=<jsonnet-bundler-version>]
#	                  [KUBECTL_VER=<kubectl-version>]
#	                  [PYTHON_VER=<python-version>]
#	                  [TERRAFORM_VER=<terraform-version>]

github_url := $(strip $(or $(GITHUB_SERVER_URL),https://github.com))
github_repo := $(strip $(or $(GITHUB_REPOSITORY),$(OWNER)/$(NAME)))

docker.image:
	docker build --network=host --force-rm \
		$(if $(call eq,$(no-cache),yes),--no-cache --pull,) \
		--build-arg image_ver=$(IMAGE_VER) \
		--build-arg ansible_ver=$(ANSIBLE_VER) \
		--build-arg biome_ver=$(BIOME_VER) \
		--build-arg butane_ver=$(BUTANE_VER) \
		--build-arg deno_ver=$(DENO_VER) \
		--build-arg doctl_ver=$(DOCTL_VER) \
		--build-arg hcloud_ver=$(HCLOUD_VER) \
		--build-arg helm_ver=$(HELM_VER) \
		--build-arg jsonnet_ver=$(JSONNET_VER) \
		--build-arg jsonnet_bundler_ver=$(JSONNET_BUNDLER_VER) \
		--build-arg kubectl_ver=$(KUBECTL_VER) \
		--build-arg python_ver=$(PYTHON_VER) \
		--build-arg terraform_ver=$(TERRAFORM_VER) \
		--label org.opencontainers.image.source=$(github_url)/$(github_repo) \
		--label org.opencontainers.image.revision=$(strip \
			$(shell git show --pretty=format:%H --no-patch)) \
		--label org.opencontainers.image.version=$(strip \
			$(shell git describe --tags --dirty)) \
		-t $(OWNER)/$(NAME):$(or $(tag),$(VERSION)) ./


# Manually push Docker images to container registries.
#
# Usage:
#	make docker.push [tags=($(TAGS)|<docker-tag-1>[,<docker-tag-2>...])]
#	                 [registries=($(REGISTRIES)|<prefix-1>[,<prefix-2>...])]

docker.push:
	$(foreach tag,$(subst $(comma), ,$(docker-tags)),\
		$(foreach registry,$(subst $(comma), ,$(docker-registries)),\
			$(call docker.push.do,$(registry),$(tag))))
define docker.push.do
	$(eval repo := $(strip $(1)))
	$(eval tag := $(strip $(2)))
	docker push $(repo)/$(OWNER)/$(NAME):$(tag)
endef


# Tag Docker image with the given tags.
#
# Usage:
#	make docker.tags [of=($(VERSION)|<docker-tag>)]
#	                 [tags=($(TAGS)|<docker-tag-1>[,<docker-tag-2>...])]
#	                 [registries=($(REGISTRIES)|<prefix-1>[,<prefix-2>...])]

docker.tags:
	$(foreach tag,$(subst $(comma), ,$(docker-tags)),\
		$(foreach registry,$(subst $(comma), ,$(docker-registries)),\
			$(call docker.tags.do,$(or $(of),$(VERSION)),$(registry),$(tag))))
define docker.tags.do
	$(eval from := $(strip $(1)))
	$(eval repo := $(strip $(2)))
	$(eval to := $(strip $(3)))
	docker tag $(OWNER)/$(NAME):$(from) $(repo)/$(OWNER)/$(NAME):$(to)
endef


# Save Docker images to a tarball file.
#
# Usage:
#	make docker.tar [to-file=(.cache/image.tar|<file-path>)]
#	                [tags=($(VERSION)|<docker-tag-1>[,<docker-tag-2>...])]

docker-tar-file = $(or $(to-file),.cache/image.tar)

docker.tar:
	mkdir -p $(dir $(docker-tar-file))
	docker save -o $(docker-tar-file) \
		$(foreach tag,$(subst $(comma), ,$(or $(tags),$(VERSION))),\
			$(OWNER)/$(NAME):$(tag))


docker.test: test.docker


# Load Docker images from a tarball file.
#
# Usage:
#	make docker.untar [from-file=(.cache/image.tar|<file-path>)]

docker.untar:
	docker load -i $(or $(from-file),.cache/image.tar)




####################
# Testing commands #
####################

# Run Bats tests for Docker image.
#
# Documentation of Bats:
#	https://github.com/bats-core/bats-core
#
# Usage:
#	make test.docker [tag=($(VERSION)|<docker-tag>)]

test.docker:
ifeq ($(wildcard node_modules/.bin/bats),)
	@make npm.install
endif
	IMAGE=$(OWNER)/$(NAME):$(or $(tag),$(VERSION)) \
	node_modules/.bin/bats \
		--timing $(if $(call eq,$(CI),),--pretty,--formatter tap) \
		--print-output-on-failure \
		tests/main.bats




################
# NPM commands #
################

# Resolve project NPM dependencies.
#
# Usage:
#	make npm.install [dockerized=(no|yes)]

npm.install:
ifeq ($(dockerized),yes)
	docker run --rm --network=host -v "$(PWD)":/app/ -w /app/ \
		node:$(NODE_VER) \
			make npm.install dockerized=no
else
	npm install
endif




##################
# Biome commands #
##################

# Format sources with Biome.
#
# Usage:
#	make biome.fmt [check=(no|yes)] [dockerized=(no|yes)]

biome.fmt:
ifeq ($(dockerized),yes)
	docker run --rm -v "$(PWD)":/app/ -w /app/ \
		ghcr.io/biomejs/biome:$(BIOME_VER) \
			format . $(if $(call eq,$(check),yes),,--write)
else
	biome format . $(if $(call eq,$(check),yes),,--write)
endif




################
# Git commands #
################

# Release project version (apply version tag and push).
#
# Usage:
#	make git.release [ver=($(VERSION)|<proj-ver>)]

git-release-tag = $(strip $(or $(ver),$(VERSION)))

git.release:
ifeq ($(shell git rev-parse $(git-release-tag) >/dev/null 2>&1 && echo "ok"),ok)
	$(error "Git tag $(git-release-tag) already exists")
endif
	git tag $(git-release-tag) main
	git push origin refs/tags/$(git-release-tag)




##################
# .PHONY section #
##################

.PHONY: fmt image push release tags test \
        biome.fmt \
        docker.image docker.push docker.tags docker.tar docker.test \
        docker.untar \
        git.release \
        npm.install \
        test.docker
