ANSIBLE_DISPLAY_SKIPPED_HOSTS:=false
export ANSIBLE_DISPLAY_SKIPPED_HOSTS

EXECUTABLES = ansible-playbook docker
42 := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),ERROR: ,$(error "No $(exec) not installed")))

LE_NET_SET := $(shell docker network inspect localenv >/dev/null 2>&1 || docker network create localenv >/dev/null 2>&1)
LE_NET_GW  := $(shell docker network inspect localenv --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}' )
OS_NAME    := $(shell uname -s | tr A-Z a-z)
GID        := $(shell id -g ${USER})
UID        := $(shell id -u ${USER})
export LE_NET_GW
export GID
export UID

.PHONY: init

render:
	@ansible-playbook -i inventory render.yml

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

init: render deploy-localenv

-include ./Makefile.deploy
