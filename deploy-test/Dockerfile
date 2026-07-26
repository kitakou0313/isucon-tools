FROM ubuntu:24.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y openssh-server nginx mysql-server tzdata rsync sudo
RUN mkdir /var/run/sshd

# This container has no systemd (PID 1 is entrypoint.sh), so the real systemctl
# fails with "System has not been booted with systemd as init system". Stub it
# out so deploy/deloy.sh's `systemctl restart` step succeeds in this test env.
RUN printf '#!/bin/sh\necho "[deploy-test stub] systemctl $*"\nexit 0\n' > /usr/bin/systemctl \
  && chmod +x /usr/bin/systemctl
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22

COPY ./access.log.example /var/log/nginx/access.log
COPY ./mysql-slow.log.example /var/log/mysql/mysql-slow.log
COPY ./fgprof.pprof.example /tmp/pprof/fgprof.pprof
COPY ./id_rsa/id_rsa.pub /root/authorized_keys

WORKDIR /root

RUN mv ~/authorized_keys ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys

RUN mkdir -p webapp/isucon
RUN mkdir -p webapp/isucon/sql
COPY entrypoint.sh ./
CMD ["./entrypoint.sh"]
