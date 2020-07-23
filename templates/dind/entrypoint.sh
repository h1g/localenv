#!/bin/sh

cleanup() {
[ -f "/tmp/eventlistner.pid" ] && kill `cat /tmp/eventlistner.pid`
sed '/#Localenv hosts records/,$d' /etc/hosts.docker > /tmp/hosts.docker && cat /tmp/hosts.docker > /etc/hosts.docker
}

cleanup

format="{{.NetworkSettings.Networks.localenv.IPAddress}} {{ join .NetworkSettings.Networks.localenv.Aliases \" \"}}"
[ $(cat /etc/hosts|grep host.docker.internal|wc -l) -eq 0 ] && format="127.0.0.1 {{ join .NetworkSettings.Networks.localenv.Aliases \" \"}}"

echo "#Localenv hosts records" >> /etc/hosts.docker
cat /etc/hosts|grep host.docker.internal >> /etc/hosts.docker
docker inspect --format "${format}" $(docker ps --format {{.ID}})|awk '{if (NF>1 && $1!="<no") print $0}' >> /etc/hosts.docker

docker events --filter 'event=start' --filter 'event=stop' --format '{{.Status}} {{.ID}}'|while read line;
do
  sed "/$(docker inspect --format '{{.Name}}' $(echo $line|cut -d' ' -f2)|sed 's/\///')/d" /etc/hosts.docker > /tmp/hosts.docker && cat /tmp/hosts.docker > /etc/hosts.docker
  [ "$(echo $line|cut -d' ' -f1)" == "start" ] && docker inspect --format "${format}" $(echo $line|cut -d' ' -f2)|awk '{if (NF>1 && $1!="<no") print $0}' >> /etc/hosts.docker
done &

echo $! > /tmp/eventlistner.pid

trap cleanup SIGINT SIGTERM

while kill -0 $! > /dev/null 2>&1; do
  wait
done
