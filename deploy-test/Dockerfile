FROM ubuntu:20.04

ARG PASSWD

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y openssh-server nginx mysql-server tzdata
RUN mkdir /var/run/sshd
RUN echo 'root:'${PASSWD} | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22

WORKDIR /horm/root
COPY entrypoint.sh ./
CMD ["./entrypoint.sh"]