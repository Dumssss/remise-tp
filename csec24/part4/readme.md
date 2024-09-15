# Partie 4 : Autour de l'application

Dans cette dernière partie, on va s'intéresser toujours à améliorer le niveau de sécurité de l'application.  
Mais cette fois-ci en s'intéressant un peu plus à ce qu'on peut faire à l'extérieur du service.

## Sommaire

- [Partie 4 : Autour de l'application](#partie-4--autour-de-lapplication)
  - [Sommaire](#sommaire)
  - [1. Firewalling](#1-firewalling)
  - [2. Protéger l'app contre le flood](#2-protéger-lapp-contre-le-flood)
  - [3. Empêcher le programme de faire des actions indésirables](#3-empêcher-le-programme-de-faire-des-actions-indésirables)

## 1. Firewalling

**Le *firewall* permet de filtrer les connexions entrantes sur la machine, mais aussi les connexions sortantes.**

🌞 **Configurer de façon robuste le firewall**

```bash
$ sudo iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
$ sudo iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
$ sudo iptables -I INPUT -p tcp --dport 8888 -j ACCEPT
$ sudo iptables -I OUTPUT -p tcp --sport 8888 -j ACCEPT
$ sudo iptables -A INPUT -i lo -j ACCEPT
$ sudo iptables -A OUTPUT -o lo -j ACCEPT
$ sudo iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
$ sudo iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
$ sudo iptables -P INPUT DROP
$ sudo iptables -P OUTPUT DROP
```
**Résultat de la configuraton**
```bash
$ sudo iptables -L
Chain INPUT (policy DROP)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:ddi-tcp-1
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:ssh
ACCEPT     all  --  anywhere             anywhere
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:ssh

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy DROP)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere             tcp spt:ddi-tcp-1
ACCEPT     tcp  --  anywhere             anywhere             tcp spt:ssh state ESTABLISHED
ACCEPT     all  --  anywhere             anywhere
ACCEPT     tcp  --  anywhere             anywhere             tcp spt:ssh state ESTABLISHED
```

🌞 **Prouver que la configuration est effective**

- prouver que les connexions sortantes sont bloquées
```bash
$ curl example.com
curl: (6) Could not resolve host: example.com
```
- prouver que les pings sont bloqués, mais une connexion SSH fonctionne
```bash
$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
--- 8.8.8.8 ping statistics ---
72 packets transmitted, 0 received, 100% packet loss, time 71364ms
```

## 2. Protéger l'app contre le flood

🌞 **Installer fail2ban sur la machine**
```bash
sudo dnf install epel-release
sudo dnf install fail2ban
```

🌞 **Ajouter une *jail* fail2ban**

```bash
[DEFAULT]
enabled  = true
port     = ssh
logpath  = /var/log/efrei_serverlog/server.log
maxretry = 3
findtime = 600
bantime  = 600

[sshd]
enabled  = true
filter   = sshd
action   = iptables[name=SSH, port=ssh, protocol=tcp]
```

🌞 **Vérifier que ça fonctionne !**

```bash
for i in {1..10}; do ssh -p 22 dums@192.168.56.101 -vvv; done
```
```bash
$ ssh dums@192.168.56.101
ssh_connect: connect failed: Connection refused
```
```bash
$ sudo fail2ban-client set sshd unbanip 192.168.56.101
```

## 3. Empêcher le programme de faire des actions indésirables

```bash
sudo dnf install seccomp-tools
```

```bash
sudo seccomp-tool generate --default allow --add syscalls=open,read,write,close,socket,connect,bind,listen,recv,send,mmap,munmap,exit_group > /usr/local/bin/efrei_server/seccomp.policy
```
```bash
[Unit]
Description=Super serveur EFREI

[Service]
ExecStart=/usr/local/bin/efrei_server/app
Seccomp=/usr/local/bin/efrei_server/seccomp.policy

EnvironmentFile=/usr/local/bin/efrei_server/env
Restart=always
User=efreiuser
```
```bash
sudo systemctl daemon-reload
sudo systemctl restart efrei_server
```