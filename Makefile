ifeq (,$(shell which docker))
	$(error "Error: docker self-sufficient runtime for containers not available")
endif
ifeq (,$(wildcard ${HOME}/.ssh/id_rsa))
	$(error "Error: ${HOME}/.ssh/id_rsa - ssh private key does not exist. Run: ssh-keygen")
endif
ifeq (,$(wildcard ${HOME}/.gitconfig))
	$(error "Error: ${HOME}/.gitconfig - gitconfig key does not exist. Run: git config --global user.name 'John Deploy'; git config --global user.email 'johndeploy@example.com'")
endif

export OS_NAME := $(shell uname -s | tr A-Z a-z)
ifeq ($(OS_NAME),linux)
ifeq (,$(shell id -Gn ${USER}|grep docker))
    $(error "User:${USER} not in docker group. Run: sudo usermod -aG docker ${USER} and reboot")
endif
DOCKER_GID :=$(shell stat -c%g /var/run/docker.sock)
ifdef WSL_DISTRO_NAME
export OS_NAME := "wsl"
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
endif

docker-bootstrap :=docker run --rm -v '/var/run/docker.sock:/var/run/docker.sock' -v '${PWD}:${PWD}' -e 'WORK_DIR=${PWD}' -v '${HOME}/.ssh:${HOME}/.ssh'
ifdef SSH_AUTH_SOCK
docker-bootstrap +=-e SSH_AUTH_SOCK=${SSH_AUTH_SOCK} -e SSH_AGENT_PID=${SSH_AGENT_PID} -v '${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK}'
endif
docker-bootstrap +=localenv


.PHONY: install

build:
	@docker network inspect localenv >/dev/null 2>&1 || docker network create localenv >/dev/null 2>&1
	@$(eval export LE_NET_GW := $(shell docker network inspect localenv --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}'))
	docker build --build-arg UID=$(shell id -u) --build-arg GID=$(shell id -g) --build-arg USER=${USER} --build-arg HOME=${HOME} --build-arg WORKDIR=${PWD} --build-arg OS_NAME=${OS_NAME} --build-arg DOCKER_GID=${DOCKER_GID} --build-arg LE_NET_GW=${LE_NET_GW} -t localenv .
render:
	$(docker-bootstrap) ansible-playbook -i inventory render.yml

core:
	@make deploy-localenv-core

install: build render core

-include ./infra/Makefile