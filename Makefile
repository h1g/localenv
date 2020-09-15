EXECUTABLES = docker
42 := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),ERROR: ,$(error "No $(exec) not installed")))
43 := $(if $(shell id -Gn ${USER}|grep docker),ERROR: ,$(error "User:${USER} not in docker group. Run: sudo usermod -aG docker ${USER} and reboot"))

LE_NET_SET := $(shell docker network inspect localenv >/dev/null 2>&1 || docker network create localenv >/dev/null 2>&1)
OS_NAME    := $(shell uname -s | tr A-Z a-z)
localenv   := docker run --rm -v '/var/run/docker.sock:/var/run/docker.sock' -v '${HOME}:${HOME}' localenv

.PHONY: init

deploy:
	@docker build --build-arg UID=$(shell id -u) --build-arg GID=$(shell id -g) --build-arg USER=${USER} --build-arg HOME=${HOME} --build-arg WORKDIR=${PWD} --build-arg LE_NET_GW=$(shell docker network inspect localenv --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}' ) -t localenv .
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
	@$(MAKE) deploy-dev-localenvmac
endif

init: deploy render deploy-localenv

-include ./Makefile.deploy
