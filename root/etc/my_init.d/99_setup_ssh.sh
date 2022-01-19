#!/bin/bash
 
shopt -s nocasematch
: ${APP_PASSWORD:=""}
: ${SSH_PUBLIC_KEY:=""}

mkdir -p /var/www/.ssh
mkdir -p /var/run/sshd
usermod -d /var/www app
usermod -s /bin/bash app

if [[ $SSH_PUBLIC_KEY != "" ]]
then
    sed -ri 's/^#?PasswordAuthentication\s+.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    echo "${SSH_PUBLIC_KEY}" > /var/www/.ssh/authorized_keys
    chmod 600 /var/www/.ssh/authorized_keys
elif [[ $APP_PASSWORD != "" ]]
then
    echo "app:${APP_PASSWORD}" | chpasswd
else
    echo "app:whmcsapp" | chpasswd
fi

# FIX ssh permission
chown -R app:app /var/www/.ssh
chmod 700 /var/www/.ssh

# add ssh to upstart
if [[ -f /etc/service/sshd/down ]]; then
    rm -f /etc/service/sshd/down
fi
