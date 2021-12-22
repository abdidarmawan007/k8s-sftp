#!/bin/bash
set -e

printf "\n\033[0;44m---> Creating SSH master user.\033[0m\n"

useradd -m -d /home/${SFTP_MASTER_USER} ${SFTP_MASTER_USER} -s /usr/sbin/nologin
echo "${SFTP_MASTER_USER}:${SFTP_MASTER_PASS}" | chpasswd

addgroup sftp
usermod -aG sftp ${SFTP_MASTER_USER}

exec "$@"