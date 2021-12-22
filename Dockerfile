FROM debian:buster-20210902

ARG SFTP_MASTER_USER=sftp_zeus
ARG SFTP_MASTER_PASS=Swn2iApSftpW94nvL2g7S
ENV TINI_VERSION=v0.18.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server gnupg cron wget curl nano sudo tcpd && \
    mkdir /run/sshd && \
    rm -rf /var/lib/apt/lists/*

## tini protects from creates zombie processes
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

## install a golang port of supervisord
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/bin/supervisord
COPY /docker-config/supervisord.conf /supervisord.conf

## copy ssh/sftp config, create user
COPY /docker-config/ssh_host_ecdsa_key /etc/ssh/ssh_host_ecdsa_key
COPY /docker-config/ssh_host_ecdsa_key.pub /etc/ssh/ssh_host_ecdsa_key.pub
COPY /docker-config/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key
COPY /docker-config/ssh_host_ed25519_key.pub /etc/ssh/ssh_host_ed25519_key.pub
COPY /docker-config/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key
COPY /docker-config/ssh_host_rsa_key.pub /etc/ssh/ssh_host_rsa_key.pub
#COPY /docker-config/ssh_config /etc/ssh/ssh_config
COPY /docker-config/sshd_config /etc/ssh/sshd_config
COPY /docker-config/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY /docker-config/user.sh /usr/local/bin/user.sh
COPY /docker-config/crontab-sftp.txt /home/${SFTP_MASTER_USER}/crontab-sftp.txt

RUN chmod +x /usr/local/bin/user.sh && \
    /usr/local/bin/user.sh && \
    rm /usr/local/bin/user.sh && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    chmod +x /tini && \
    /usr/bin/crontab /home/${SFTP_MASTER_USER}/crontab-sftp.txt && \
    touch /var/log/cron.log 

RUN mkdir /home/${SFTP_MASTER_USER}/.ssh
COPY /docker-config/authorized_keys /home/${SFTP_MASTER_USER}/.ssh/authorized_keys
RUN chown root:root /home/${SFTP_MASTER_USER} && \
    chmod 700 /home/${SFTP_MASTER_USER}/.ssh && \
    chmod 400 /home/${SFTP_MASTER_USER}/.ssh/authorized_keys && \
    chown -R ${SFTP_MASTER_USER}:${SFTP_MASTER_USER} /home/${SFTP_MASTER_USER}/.ssh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD tail -f /dev/null
