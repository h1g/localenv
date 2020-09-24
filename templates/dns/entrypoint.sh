#!/bin/bash

cleanup() {
[ -f "/tmp/eventlistner.pid" ] && kill $(cat /tmp/eventlistner.pid)
sed '/#Localenv hosts records/,$d' /etc/hosts.docker > /tmp/hosts.docker && cat /tmp/hosts.docker > /etc/hosts.docker
}

cleanup

format="{{.NetworkSettings.Networks.localenv.IPAddress}} {{ join .NetworkSettings.Networks.localenv.Aliases \" \"}}"
[ "$(grep -c host.docker.internal /etc/hosts)" -eq 0 ] && format="127.0.0.1 {{ join .NetworkSettings.Networks.localenv.Aliases \" \"}}"
tail -c1 /etc/hosts.docker | read -r _ || echo >> /etc/hosts.docker
{ echo "#Localenv hosts records"; grep -w host.docker.internal /etc/hosts; docker inspect --format "${format}" $(docker ps --format {{.ID}})|awk '{if (NF>1 && $1!="<no") print $0}'; } >> /etc/hosts.docker

docker events --filter 'event=start' --filter 'event=stop' --format '{{.Status}} {{.ID}} {{.Actor.Attributes.name}}'|while read -r -a info;
do
  if [ "${info[0]}" == "start" ];then
    docker inspect --format "${format}" ${info[1]}|awk '{if (NF>1 && $1!="<no") print $0}' >> /etc/hosts.docker
  else
    sed "/${info[2]}/d" /etc/hosts.docker > /tmp/hosts.docker && cat /tmp/hosts.docker > /etc/hosts.docker
  fi
done &
echo $! > /tmp/eventlistner.pid

trap cleanup SIGINT SIGTERM

while kill -0 $! > /dev/null 2>&1; do
  wait
done
