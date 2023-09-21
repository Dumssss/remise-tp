# **Rendu TP1**
## I. Most simplest LAN
### Déterminer l'adresse MAC de vos deux machines 
```
ip a
```
**Résultat :**
```
link/either 08:00:27:da:e1:07
```
### ️ Définir une IP statique sur les deux machines
**On va créer et/ou modifier le fichier de configuration réseau situé dans /etc/sysconfig/network-script/ifcfg-enp0s3**
```
sudo nano /etc/sysconfig/network-script/ifcfg-enp0s3
```
**Puis on le complète comme suit pour la première machine :**
```
NAME=enp0s3
DEVICE=enp0s3

BOOTPROTO=static
ONBOOT=yes

IPADDR=10.1.1.1
NETMASK=255.255.255.0
```
**Pour la deuxième machine :**
```
NAME=enp0s3
DEVICE=enp0s3

BOOTPROTO=static
ONBOOT=yes

IPADDR=10.1.1.2
NETMASK=255.255.255.0
```
**Une fois cela fait, on  recharge la configuration des connexions réseau gérées par NetworkManager à l'aide la commande suivante :**
```
sudo nmcli con reload
```
**Par la suite, on peut faire un**
```
ip a
```
**Pour voir si notre IP à bien été changée.**
**Voila ce que j'obtiens pour la machine 1 :**
```
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:da:e1:07 brd ff:ff:ff:ff:ff:ff
    inet 10.1.1.1/24 brd 10.1.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feda:e107/64 scope link
       valid_lft forever preferred_lft forever
```
**Et pour la machine 2 :**
```
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:cb:68:e1 brd ff:ff:ff:ff:ff:ff
    inet 10.1.1.2/24 brd 10.1.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fecb:68e1/64 scope link tentative
       valid_lft forever preferred_lft forever
```
### Effectuer un ping d'une machine à l'autre
**Pour cela nous utilisons la commande**
```ping```
**Vers l'IP de la deuxième machine**
**Par exemple, pour ping de la machine 1 vers la machine 2 :**
```
ping 10.1.1.2
```
**Voila le resultat que l'on obtient :**
```
ping 10.1.1.2
PING 10.1.1.2 (10.1.1.2) 56(84) bytes of data.
64 bytes from 10.1.1.2: icmp_seq=1 ttl=64 time=2.47 ms
^C
--- 10.1.1.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 2.472/2.472/2.472/0.000 ms
```
### A l'aide de Wireshark
Le protocole utilisé pour la capture est le protocole ICMP
## II. Ajoutons un switch
**D'abord on ajoute la machine 3 (clone de la machine principale comme les autres) et on change son adresse IP**
```sudo nano /etc/sysconfig/network-scripts/ifcfg-enp0s3```
```
NAME=enp0s3
DEVICE=enp0s3

BOOTPROTO=static
ONBOOT=yes

IPADDR=10.1.1.3
NETMASK=255.255.255.0
```
