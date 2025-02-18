# Part II : Networking

Le réseau c'est la porte d'entrée pour toutes les autres machines. C'est le seul moyen d'être attaqué à distance.

Maîtriser au mieux le réseau d'une machine est donc primordial pour prétendre en renforcer la sécurité.

## Index

- [Part II : Networking](#part-ii--networking)
  - [Index](#index)
  - [1. Basic networking conf](#1-basic-networking-conf)
    - [A. Static IP](#a-static-ip)
    - [B. Hostname](#b-hostname)
  - [2. Listening ports](#2-listening-ports)
  - [3. Firewalling](#3-firewalling)

## 1. Basic networking conf

### A. Static IP

🌞 **Attribuer l'adresse IP `10.1.1.11/24`** à la VM

```bash
$ ip a

$ cd /etc/sysconfig/network-scripts

$ sudo nano ifcfg-enp0s8

$ sudo cat ifcfg-enp0s8
DEVICE=enp0s8
NAME=lan

BOOTPROTO=static
ONBOOT=yes

IPADDR=10.1.1.11
NETMASK=255.255.255.0

$ sudo nmcli con reload

$ sudo nmcli con up lan 
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/6)
```

### B. Hostname

🌞 **Attribuer le nom `node1.tp1.b3` à la VM**

```PS
sudo hostnamectl set-hostname node1.tp1.b3

[dums@vbox ~]$ sudo hostnamectl status
 Static hostname: node1.tp1.b3
 ...
```
## 2. Listening ports

🌞 **Déterminer la liste des programmes qui écoutent sur un port TCP**
```PS
[dums@vbox ~]$ ss -tlen
State   Recv-Q  Send-Q   Local Address:Port   Peer Address:Port  Process
LISTEN  0       128            0.0.0.0:22          0.0.0.0:*      ino:17066 sk:2 cgroup:/system.slice/sshd.service <->
LISTEN  0       128               [::]:22             [::]:*      ino:17079 sk:3 cgroup:/system.slice/sshd.service v6only:1 <->
```

🌞 **Déterminer la liste des programmes qui écoutent sur un port UDP**

```PS
[dums@vbox ~]$ ss -ulen
State  Recv-Q  Send-Q   Local Address:Port   Peer Address:Port Process
UNCONN 0       0            127.0.0.1:323         0.0.0.0:*     ino:16548 sk:4 cgroup:/system.slice/chronyd.service <->
UNCONN 0       0                [::1]:323            [::]:*     ino:16549 sk:5 cgroup:/system.slice/chronyd.service v6only:1 <->
```

## 3. Firewalling

➜ **Vous pouvez afficher l'état actuel de `firewalld`, le firewall de Rocky Linux, avec :**

```bash
sudo firewall-cmd --list-all
```

🌞 **Pour chacun des ports précédemment repérés...**

- montrez qu'il existe une règle firewall qui autorise le trafic entrant sur ce port

```PS
[dums@vbox ~]$ sudo firewall-cmd --zone=public --query-port=22/tcp
no
[dums@vbox ~]$ sudo firewall-cmd --zone=public --query-port=323/tcp
no
```

> **Attention !** Le firewall de Rocky Linux, `firewalld`, a deux concepts pour ouvrir un port TCP/UDP. Soit on ouvre... un port avec `--add-port` et on le voit apparaître devant `ports:`. Soit on ouvre un "service" avec `--add-service` et on le voit apparaître devant `services:`. Chaque "service" est donc un port ouvert (et à fermer potentiellement à la question suivante ;) ).

🌞 **Fermez tous les ports inutilement ouverts dans le firewall**

```PS
[dums@vbox ~]$ sudo firewall-cmd --remove-service samba-client --permanent
success
[dums@vbox ~]$ sudo firewall-cmd --remove-service mdns --permanent
success
[dums@vbox ~]$ sudo firewall-cmd --remove-service dhcpv6-client --permanent
success
[dums@vbox ~]$ sudo firewall-cmd --remove-service cockpit --permanent
success
```

🌞 **Pour toutes les applications qui sont en écoute sur TOUTES les adresses IP**

```PS
[dums@node1 ~]$ sudo nano /etc/ssh/sshd_config
#Port 22
#AddressFamily any
ListenAddress 10.1.1.11
#ListenAddress ::
[dums@node1 ~]$ sudo systemctl restart sshd
[dums@node1 ~]$ sudo grep -w -i listenaddress /etc/ssh/sshd_config
ListenAddress 10.1.1.11
#ListenAddress :: 
[dums@node1 ~]$ sudo systemctl status sshd
Feb 17 18:05:19 node1.tp1.b3 systemd[1]: Starting OpenSSH server daemon...
Feb 17 18:05:19 node1.tp1.b3 sshd[1442]: Server listening on 10.1.1.11 port 22.
Feb 17 18:05:19 node1.tp1.b3 systemd[1]: Started OpenSSH server daemon.
```
Suite --> [Partie 3](./part3.md)