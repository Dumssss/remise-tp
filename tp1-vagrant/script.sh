#!/bin/bash
dnf update -y

# Install de vim et python3 pour la partie 2
dnf install -y vim python3

# Install et activation de cloud init pour la partie 5
dnf install -y cloud-init
systemctl enable cloud-init
