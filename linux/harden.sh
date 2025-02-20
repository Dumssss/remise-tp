#!/bin/bash

# Vérifier que SSH est démarré
systemctl is-active sshd || systemctl start sshd

# Vérifier et modifier le port SSH si nécessaire
if grep -q "^Port 22" /etc/ssh/sshd_config; then
    sed -i 's/^Port 22/Port 33000/' /etc/ssh/sshd_config
    systemctl restart sshd
fi

# Appliquer les configurations de sécurité SSH
sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# Vérifier que Fail2Ban est installé et démarré
command -v fail2ban-client &>/dev/null || dnf install -y fail2ban
systemctl enable fail2ban

# Vérifier que Fail2Ban surveille SSH
if ! grep -q "\[sshd\]" /etc/fail2ban/jail.local; then
    echo -e "[sshd]\nenabled = true" >> /etc/fail2ban/jail.local
    systemctl restart fail2ban
fi

# Afficher l'état de Fail2Ban pour SSH
fail2ban-client status sshd
