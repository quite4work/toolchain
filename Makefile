######################
# Project parameters #
######################

MAINLINE_BRANCH := master
CURRENT_BRANCH := $(shell git branch | grep \* | cut -d ' ' -f2)

IMAGE_VER ?= $(strip \
	$(shell grep 'ARG image_ver=' Dockerfile | cut -d '=' -f2))
DOCKER_VER ?= $(strip \
	$(shell grep 'ARG docker_ver=' Dockerfile | cut -d '=' -f2))
DOCKER_COMPOSE_VER ?= $(strip \
	$(shell grep 'ARG docker_compose_ver=' Dockerfile | cut -d '=' -f2))
KUBECTL_VER ?= $(strip \
	$(shell grep 'ARG kubectl_ver=' Dockerfile | cut -d '=' -f2))
HELM_VER ?= $(strip \
	$(shell grep 'ARG helm_ver=' Dockerfile | cut -d '=' -f2))
REG_VER ?= $(strip \
	$(shell grep 'ARG reg_ver=' Dockerfile | cut -d '=' -f2))
GITLAB_RELEASE_CLI_VER ?= $(strip \
	$(shell grep 'ARG gitlab_release_cli_ver=' Dockerfile | head -1 \
	                                                      | cut -d '=' -f2))

NAME := gitlab-builder
OWNER := $(or $(GITHUB_REPOSITORY_OWNER),instrumentisto)
REGISTRIES := $(strip $(subst $(comma), ,\
	$(shell grep -m1 'registry: \["' .github/workflows/ci.yml \
	        | cut -d':' -f2 | tr -d '"][')))
TAGS ?= $(IMAGE_VER)-docker$(DOCKER_VER)-compose$(DOCKER_COMPOSE_VER)-kubectl$(KUBECTL_VER)-helm$(HELM_VER)-reg$(REG_VER)-releasecli$(GITLAB_RELEASE_CLI_VER) \
        $(IMAGE_VER) \
        $(strip $(shell echo $(IMAGE_VER) | cut -d '.' -f1,2)) \
        latest
VERSION ?= $(word 1,$(subst $(comma), ,$(TAGS)))




###########
# Aliases #
###########

squash: git.squash




###################
# Docker commands #
###################

docker-registries = $(strip \
	$(or $(subst $(comma), ,$(registries)),$(REGISTRIES)))
docker-tags = $(strip $(or $(subst $(comma), ,$(tags)),$(TAGS)))


# Build Docker image with the given tag.
#
# Usage:
#	make docker.image [tag=($(VERSION)|<docker-tag>)]] [no-cache=(no|yes)]
#	                  [IMAGE_VER=<image-version>]
#	                  [DOCKER_VER=<docker-version>]
#	                  [DOCKER_COMPOSE_VER=<docker-compose-version>]
#	                  [KUBECTL_VER=<kubectl-version>]
#	                  [HELM_VER=<helm-version>]
#	                  [REG_VER=<reg-version>]
#	                  [GITLAB_RELEASE_CLI_VER=<gitlab-release-cli-version>]

github_url := $(strip $(or $(GITHUB_SERVER_URL),https://github.com))
github_repo := $(strip $(or $(GITHUB_REPOSITORY),$(OWNER)/$(NAME)-docker-image))

docker.image:
	docker build --network=host --force-rm \
		$(if $(call eq,$(no-cache),yes),--no-cache --pull,) \
		--build-arg image_ver=$(IMAGE_VER) \
		--build-arg docker_ver=$(DOCKER_VER) \
		--build-arg docker_compose_ver=$(DOCKER_COMPOSE_VER) \
		--build-arg kubectl_ver=$(KUBECTL_VER) \
		--build-arg helm_ver=$(HELM_VER) \
		--build-arg reg_ver=$(REG_VER) \
		--build-arg gitlab_release_cli_ver=$(GITLAB_RELEASE_CLI_VER) \
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
	@mkdir -p $(dir $(docker-tar-file))
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




################
# Git commands #
################

# Squash changes of the current Git branch onto another Git branch.
#
# WARNING: You must merge `onto` branch in the current branch before squash!
#
# Usage:
#	make git.squash [onto=(<mainline-git-branch>|<git-branch>)]
#	                [del=(no|yes)]
#	                [upstream=(origin|<git-remote>)]

onto ?= $(MAINLINE_BRANCH)
upstream ?= origin

git.squash:
ifeq ($(CURRENT_BRANCH),$(onto))
	echo "--> Current branch is '$(onto)' already" && false
endif
	git checkout $(onto)
	git branch -m $(CURRENT_BRANCH) orig-$(CURRENT_BRANCH)
	git checkout -b $(CURRENT_BRANCH)
	git branch --set-upstream-to $(upstream)/$(CURRENT_BRANCH)
	git merge --squash orig-$(CURRENT_BRANCH)
ifeq ($(del),yes)
	git branch -d orig-$(CURRENT_BRANCH)
endif




##################
# .PHONY section #
##################

.PHONY: squash \
        git.squash
