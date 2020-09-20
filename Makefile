ifeq (,$(shell which docker))
    $(error "Error: docker self-sufficient runtime for containers not available")
endif
ifeq (,$(wildcard ${HOME}/.ssh/id_rsa))
    $(error "Error: ${HOME}/.ssh/id_rsa - ssh private key does not exist. Run: ssh-keygen")
endif
ifeq (,$(wildcard ${HOME}/.gitconfig))
    $(error "Error: ${HOME}/.gitconfig - gitconfig key does not exist. Run: git config --global user.name 'John Deploy'; git config --global user.email 'johndeploy@example.com'")
endif

OS_NAME := $(shell uname -s | tr A-Z a-z)
UID := $(shell id -u)
GID := $(shell id -g)
LE_NET_GW := $(shell docker network inspect localenv --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}' )

docker-wrapper		:= docker run --rm -v '/var/run/docker.sock:/var/run/docker.sock' -v '${HOME}:${HOME}' localenv
ansible-playbook	:= $(docker-wrapper) ansible-playbook

ifeq (,$(shell which docker-compose))
docker-compose := $(docker-wrapper) docker-compose
else
docker-compose := $(shell which docker-compose)
endif
ifeq (,$(shell which ansible-playbook))
ansible-playbook := $(docker-wrapper) ansible-playbook
else
ansible-playbook := $(shell which ansible-playbook)
endif
ifeq (,$(shell which rsync))
rsync := $(docker-wrapper) rsync
else
rsync := $(shell which rsync)
endif
ifeq (,$(shell which git))
git := $(docker-wrapper) git
else
git := $(shell which git)
endif


ifeq ($(OS_NAME),linux)
ifdef WSL_DISTRO_NAME
OS_NAME := "wsl"
endif
endif


ifeq ($(OS_NAME),linux)
ifeq (,$(shell id -Gn ${USER}|grep docker))
    $(error "User:${USER} not in docker group. Run: sudo usermod -aG docker ${USER} and reboot")
endif
endif

ifeq ($(OS_NAME),darwin)

ifeq (,$(shell groups ${USER}|grep  wheel))
    $(error "Error: User ${USER} not in group wheel. Run: sudo dseditgroup -o edit -a ${USER} -t user wheel ")
endif
ifeq (,$(shell stat -f %A /etc/hosts|grep 664))
    $(error "Error: /etc/hosts permission denied. Run: sudo chmod 664 /etc/hosts ")
endif
$(shell sed -i~ 's/"credsStore" : "desktop"/"credStore" : "osxkeychain"/g' ~/.docker/config.json)
DOCKER_GID := "0"
else
DOCKER_GID :=$(shell getent group docker|cut -d: -f3)
endif



.PHONY: deploy

deploy:
	@docker network inspect localenv >/dev/null 2>&1 || docker network create localenv >/dev/null 2>&1
	@docker build --build-arg UID=${UID} --build-arg GID=${GID} --build-arg USER=${USER} --build-arg HOME=${HOME} --build-arg WORKDIR=${PWD} --build-arg OS_NAME=${OS_NAME} --build-arg DOCKER_GID=${DOCKER_GID} --build-arg LE_NET_GW=${LE_NET_GW} -t localenv .
render:
	@$(ansible-playbook) -i inventory render.yml

deploy-localenv:
	@$(MAKE) deploy-dev-localenv

install: deploy render deploy-localenv
export
-include ./Makefile.deploy
