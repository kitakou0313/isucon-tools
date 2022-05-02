if [ -f /var/log/mysql/mysql-slow.log ]; then 
    cp /var/log/mysql/mysql-slow.log /var/log/mysql/mysql-slow.log.bk.$(date "+%Y%m%d_%H%M%S")
    cat /dev/null > /var/log/mysql/mysql-slow.log
fi