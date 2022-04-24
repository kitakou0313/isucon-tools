if [ -f /var/log/nginx/access.log ]; then 
    mv /var/log/nginx/access.log /var/log/nginx/access.log.bk.$(date "+%Y%m%d_%H%M%S")
fi