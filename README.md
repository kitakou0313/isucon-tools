# isucon-tools
isuconで使うツール群をdockerで使えるようにまとめたtemplate


# Tools
- kataribe
    - https://github.com/matsuu/kataribe
    - Analyze web-server(nginx, etc...) access log.
- mysqlslowdump
    - Analyze mysql slow log
- pprof
    - Analyze golang application performance.


# Test scripts
- `deploy-test` container is accessible with ssh, and `nginx`, `mysql` is installed. Please use this to test your deploy scripts.

# ToDo
- Implement scripts
    - in `./bench`
    - in `./deploy`