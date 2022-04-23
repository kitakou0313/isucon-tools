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

echo "finish deploy ${USER}"