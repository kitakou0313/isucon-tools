FROM ubuntu:20.04

WORKDIR /workdir

RUN apt-get update && apt-get install -y curl

RUN curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
RUN  apt-get install -y gnupg2 lsb-release ./percona-release_latest.generic_all.deb
RUN apt-get update

RUN apt-get install -y percona-toolkit