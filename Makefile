ifeq (,$(shell which docker))
    $(error "Error: docker self-sufficient runtime for containers not available")
endif
ifeq (,$(shell id -Gn ${USER}|grep docker))
    $(error "User:${USER} not in docker group. Run: sudo usermod -aG docker ${USER} and reboot")
endif
ifeq (,$(wildcard ${HOME}/.ssh/id_rsa))
    $(error "Error: ${HOME}/.ssh/id_rsa - ssh private key does not exist. Run: ssh-keygen")
endif

ifeq (,$(wildcard ${HOME}/.gitconfig))
    $(error "Error: ${HOME}/.gitconfig - gitconfig key does not exist. Run: git config --global user.name 'FIRST_NAME LAST_NAME'; git config --global user.email 'OUR_NAME@example.com'")
endif

OS_NAME    := $(shell uname -s | tr A-Z a-z)
localenv   := docker run --rm -v '/var/run/docker.sock:/var/run/docker.sock' -v '${HOME}:${HOME}' localenv

.PHONY: deploy

deploy:
	@docker network inspect localenv >/dev/null 2>&1 || docker network create localenv >/dev/null 2>&1
	@docker build --build-arg UID=$(shell id -u) --build-arg GID=$(shell id -g) --build-arg USER=${USER} --build-arg HOME=${HOME} --build-arg WORKDIR=${PWD} --build-arg DOCKER_GID=$(shell getent group docker|cut -d: -f3) --build-arg LE_NET_GW=$(shell docker network inspect localenv --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}' ) -t localenv .
render:
	@$(localenv) ansible-playbook -i inventory render.yml

deploy-localenv:
ifeq ($(OS_NAME),linux)
ifndef WSL_DISTRO_NAME
	@$(MAKE) deploy-dev-localenv
else
	@$(MAKE) deploy-dev-localenvwsl
endif
endif
ifeq ($(OS_NAME),darwin)
	@$(MAKE) deploy-dev-localenosx
endif

install: deploy render deploy-localenv

init: install

-include ./Makefile.deploy
