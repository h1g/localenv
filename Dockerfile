FROM gnovicov/localdev:latest
FROM docker:dind
RUN apk add -u python3 bash mc ansible docker-compose shadow sudo git
ARG USER=johndeploy
ARG UID=1337
ARG GID=1337
ARG DOCKER_GID=$GID
ARG HOME=/home/$USER
ARG WORKDIR=$HOME
ARG WORK_DIR=$HOME
ARG OS_NAME=linux
ARG LE_NET_GW=127.0.0.1
ENV LE_NET_GW=$LE_NET_GW
ENV ANSIBLE_DISPLAY_SKIPPED_HOSTS=false
ENV PY_COLORS=1
ENV ANSIBLE_FORCE_COLOR=1
ENV USER=$USER
ENV OS_NAME=$OS_NAME
ENV DOCKER_GID=$DOCKER_GID
ENV WORK_DIR=$WORKDIR
ENV DEBUG_COLORS="true"
ENV TERM=xterm-256color
ENV COLORTERM=truecolor
RUN if [ $(getent group $GID) ]; then groupmod -n $USER -g $GID $(getent group $GID|cut -d ":" -f1); \
    else groupadd --gid $GID $USER; fi
RUN if [ $(getent passwd $UID) ]; then usermod -d $HOME -s /bin/bash -l $USER -u  $UID -g $GID $(getent passwd $UID|cut -d ":" -f1); mkhomedir_helper $USER; \
    else dirname $HOME | xargs mkdir -p && useradd -m --home $HOME -s /bin/bash $USER --uid  $UID --gid  $GID; fi
RUN if [ $(getent group $DOCKER_GID) ]; then groupmod -n docker -g $DOCKER_GID $(getent group $DOCKER_GID|cut -d ":" -f1); \
    else groupadd --gid $DOCKER_GID docker; fi
RUN usermod -aG docker $USER
RUN echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
COPY --from=0 /ansible /ansible
WORKDIR /ansible
USER $USER
CMD /bin/bash
