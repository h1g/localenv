ANSIBLE_DISPLAY_SKIPPED_HOSTS:=false
export ANSIBLE_DISPLAY_SKIPPED_HOSTS

LE_NET_SET := $(shell docker network inspect localenv >/dev/null 2>&1 || docker network create localenv >/dev/null 2>&1)
LE_NET_GW  := $(shell docker network inspect localenv --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}' )
OS_NAME    := $(shell uname -s | tr A-Z a-z)
GID        := $(shell id -g ${USER})
UID        := $(shell id -u ${USER})
export LE_NET_GW
export GID
export UID

render:
	@ansible-playbook -i inventory render.yml

deploy-localenv:
ifeq ($(OS_NAME),linux)
ifndef WSL_DISTRO_NAME
	@make deploy-dev-localenv
else
	@make deploy-dev-localenvwsl
endif
endif
ifeq ($(OS_NAME),darwin)
	@make deploy-dev-localenvmac
endif

init: render deploy-localenv

-include ./Makefile.deploy
