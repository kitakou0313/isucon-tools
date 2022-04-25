if [ -f /var/log/nginx/access.log ]; then 
    cp /var/log/nginx/access.log /var/log/nginx/access.log.bk.$(date "+%Y%m%d_%H%M%S")
    cat /dev/null > /var/log/nginx/access.log
fi