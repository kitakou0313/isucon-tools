FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y openssh-server nginx mysql-server tzdata rsync
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22

COPY ./access.log.example /var/log/nginx/access.log
COPY ./mysql-slow.log.example /var/log/mysql/mysql-slow.log
COPY ./cpu.pprof.example /root/webapp/cpu.pprof
COPY ./id_rsa/id_rsa.pub /root/authorized_keys

WORKDIR /root

RUN mkdir ~/.ssh
RUN mv ~/authorized_keys ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys

RUN mkdir -p webapp/isucon
RUN mkdir -p webapp/isucon/sql
COPY entrypoint.sh ./
CMD ["./entrypoint.sh"]