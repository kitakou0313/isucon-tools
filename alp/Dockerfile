FROM ubuntu:24.04

WORKDIR /workdir

RUN apt-get update && apt-get install -y wget

RUN wget https://github.com/tkuchiki/alp/releases/download/v1.0.12/alp_linux_amd64.tar.gz
RUN tar -zxvf alp_linux_amd64.tar.gz 

RUN install alp /usr/local/bin/alp
RUN rm -rf alp
RUN mkdir /workdir/alp
