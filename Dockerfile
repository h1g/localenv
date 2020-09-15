FROM docker:latest

ARG USER=johndeploy
ARG UID=1337
ARG GID=$GID
ARG HOME=/home/$USER
ARG WORKDIR=$HOME
ARG LE_NET_GW=127.0.0.1
ENV LE_NET_GW=$LE_NET_GW
ENV ANSIBLE_DISPLAY_SKIPPED_HOSTS=false
ENV PY_COLORS=1
ENV ANSIBLE_FORCE_COLOR=1
ENV USER=$USER
RUN apk -u add bash mc make git rsync docker-compose ansible
RUN addgroup -g $GID -S $USER \
&&  adduser --uid $UID --ingroup $USER -h $HOME --shell /bin/bash $USER --disabled-password \
&&  addgroup $USER ping
USER $USER
WORKDIR $WORKDIR
CMD /bin/bash
