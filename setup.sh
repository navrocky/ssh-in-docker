#!/bin/sh

set -e

REMOTE_PORT=${REMOTE_PORT:-22022}
REMOTE_HOST=${REMOTE_HOST:-}

OS_RELEASE=/etc/os-release
OS_NAME=

if [ -f ${OS_RELEASE} ]; then
  OS_NAME=`cat /etc/os-release | grep -E "^NAME=" | sed -E 's/NAME="?([^"]+)"?/\1/'`
fi

log() {
  echo "== $@"
}

fail() {
  echo "Error: $@" 1>&2
  exit 1
}

# install openssh
log "Installing openssh server and client"
if echo "$OS_NAME" | grep -q "Alpine"; then
  apk add openssh-server openssh
elif echo "$OS_NAME" | grep -qE "(Ubuntu|Debian)"; then
  apt update && DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y ssh openssh-server
elif echo "$OS_NAME" | grep -qE "(Astra)"; then
  apt update && DEBIAN_FRONTEND=noninteractive apt install -y ssh openssh-server
elif echo "$OS_NAME" | grep -qE "openSUSE"; then
  zypper in -y openssh openssh-server
else
  fail "Unsupported OS: ${OS_NAME}"
fi

ssh-keygen -A

cat /etc/ssh/sshd_config | \
sed -E 's/#PermitRootLogin .+/PermitRootLogin yes/' | \
sed -E 's/#PasswordAuthentication/PasswordAuthentication/' | \
sed -E 's/#PubkeyAuthentication yes/PubkeyAuthentication no/' | \
sed -E 's/#StrictModes yes/StrictModes no/' \
> /etc/ssh/sshd_config_new
mv /etc/ssh/sshd_config_new /etc/ssh/sshd_config

sh -c "export -p" >/setup_env.sh

log "Run ssh server"
if echo "$OS_NAME" | grep -qE "(Astra|Debian|Ubuntu)"; then
  mkdir /run/sshd
  chmod 0755 /run/sshd
fi

/usr/sbin/sshd

log "Please setup new root password"
passwd

if [ -z "${REMOTE_HOST}" ]; then
  echo -n "== Enter your remote host (user@host): "
  read REMOTE_HOST
fi

REMOTE_COMMAND="ssh-keygen -R '[localhost]:${REMOTE_PORT}' && ssh -oStrictHostKeyChecking=no -t -p ${REMOTE_PORT} root@localhost \\\"source /setup_env.sh; bash || sh\\\""

ssh -oStrictHostKeyChecking=no -R${REMOTE_PORT}:localhost:22 ${REMOTE_HOST} \
  "echo -e \"\n== Run this command on the remote host to connect inside container: \n\n$REMOTE_COMMAND\"; sleep 365d"