FROM ubuntu:20.04

WORKDIR /workdir

RUN apt-get update
RUN wget https://www.percona.com/downloads/percona-toolkit/3.0.10/binary/debian/xenial/x86_64/percona-toolkit_3.0.10-1.xenial_amd64.deb

RUN apt-get install -y gdebi
RUN gdebi percona-toolkit_3.0.10-1.xenial_amd64.deb