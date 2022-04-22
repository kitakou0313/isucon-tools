#!/bin/bash
set -e
# This scripts is used to 
# - sync setting(nginx , mysql, systemd, etc...) to remote host.

echo "Start to sync config files"

isu01="localhost"

trghosts=($isu01)

for host in "${trghosts[@]}"
do
  echo "Send configs to ${host}"
  rsync -e "ssh -p 2222" -av ../kataribe/webserver-config/nginx.conf root@${host}:/etc/nginx/nginx.conf
done

# for server in isu01 isu02 isu03; do
#     ssh -t $server "sudo systemctl stop isucon.golang.service"
#     scp ./app $server:/home/isucon/webapp/go/isucon
#     # templateは別途rsyncする必要がある
#     rsync -av ./src/isucon/views/ $server:/home/isucon/webapp/go/src/isucon/views/
#     ssh -t $server "sudo systemctl start isucon.golang.service"
# done

echo "finish deploy ${USER}"