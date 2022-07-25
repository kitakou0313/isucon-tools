FROM ubuntu:20.04

WORKDIR /workdir

RUN wget https://github.com/tkuchiki/alp/releases/download/v1.0.11/alp_linux_amd64.tar.gz
RUN tar -zcvf alp_linux_amd64.tar.gz ./

RUN install <downloaded file> /usr/local/bin/alp