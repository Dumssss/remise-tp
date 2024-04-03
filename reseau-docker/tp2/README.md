# **Rendu TP2**
## Routage
### ☀️ Configuration du router 
```
$ sudo nano /etc/sysconfig/network-scripts/ifcfg-enp0s8
NAME=enp0s8
DEVICE=enp0s8

BOOTPROTO=static
ONBOOT=yes

IPADDR=10.2.1.254
NETMASK=255.255.255.0

DNS1=1.1.1.1
```
**Résultat :**
```
$ sudo nmcli con reload
$ sudo nmcli con up enp0s8
$ ip a
[...]
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:22:de:5b brd ff:ff:ff:ff:ff:ff
    inet 10.2.1.254/24 brd 10.2.1.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe22:de5b/64 scope link 
       valid_lft forever preferred_lft forever
```
**On active le Forwarding IPv4**
```
$ sudo sysctl -w net.ipv4.ip_forward=1 
net.ipv4.ip_forward = 1

$ sudo firewall-cmd --add-masquerade
success

$ sudo firewall-cmd --add-masquerade --permanent
success
```
### ️☀️ Configuration de node1.tp2.efrei
```
$ sudo nano /etc/sysconfig/network-scripts/ifcfg-enp0s3 
NAME=enp0s3
DEVICE=enp0s3

BOOTPROTO=static
ONBOOT=yes

IPADDR=10.2.1.1
NETMASK=255.255.255.0

DNS=1.1.1.1
```
**Test de Ping**
```
$ ping 10.2.1.254
PING 10.2.1.254 (10.2.1.254) 56(84) bytes of data.
64 bytes from 10.2.1.254: icmp_seq=1 ttl=64 time=2.21 ms
```
**Configuration de la passerelle par défault**
```
$ sudo nano /etc/sysconfig/network
GATEWAY=10.2.1.254
```
**Test de Ping sur le DNS Google**
```
$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=31.3 ms
```
**Les paquets passent bien par le Router :**
```
$ traceroute 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  _gateway (10.2.1.254)  1.537 ms  1.597 ms  1.508 ms
 2  192.168.122.1 (192.168.122.1)  1.372 ms  1.554 ms  1.515 ms
 3  10.100.0.1 (10.100.0.1)  7.081 ms  7.032 ms  6.904 ms
 4  10.100.255.11 (10.100.255.11)  5.668 ms  5.619 ms  5.120 ms
 5  185.176.176.10 (185.176.176.10)  32.149 ms  32.030 ms  31.977 ms
 6  100.126.127.254 (100.126.127.254)  30.292 ms  27.643 ms  27.584 ms
 7  100.126.127.253 (100.126.127.253)  27.547 ms  27.237 ms  28.771 ms
 8  185.181.155.200 (185.181.155.200)  29.922 ms  28.660 ms  29.856 ms
 9  linkt-2.par.franceix.net (37.49.238.52)  29.819 ms  29.691 ms  29.702 ms
10  google2.par.franceix.net (37.49.236.2)  29.498 ms  29.453 ms  29.225 ms
11  108.170.244.225 (108.170.244.225)  28.937 ms 108.170.245.1 (108.170.245.1)  28.833 ms 108.170.244.193 (108.170.244.193)  29.583 ms
12  142.250.234.41 (142.250.234.41)  29.348 ms 216.239.48.139 (216.239.48.139)  32.816 ms 142.251.253.35 (142.251.253.35)  29.119 ms
13  dns.google (8.8.8.8)  28.927 ms  28.868 ms  30.861 ms
```
## Serveur DHCP
### ☀️ Installation et configuration du serveur DHCP sur dhcp.tp2.efrei
```
$ sudo nano /etc/sysconfig/network-scripts/ifcfg-enp0s3
NAME=enp0s3
DEVICE=enp0s3

BOOTPROTO=static
ONBOOT=yes

IPADDR=10.2.1.253
NETMASK=255.255.255.0

DNS1=1.1.1.1
```
**Configuration de la passerelle par défault**
```
$ sudo nano /etc/sysconfig/network
GATEWAY=10.2.1.254
```
**Redémarrage du système**
```
$ sudo nmcli con reload
$ sudo nmcli con up enp0s3
```
**Installation de DHCP**
```
sudo dnf -y install dhcp-server
```
**Configuration de DHCP**
```
sudo nano /etc/dhcp/dhcpd.conf
default-lease-time 3600;      //durée par défaut du bail DHCP
max-lease-time 86400;         //durée maximale du bail DHCP
authoritative;

subnet 10.2.1.0 netmask 255.255.255.0 {
range 10.2.1.100 10.2.1.200;
option routers 10.2.1.254;      //adresse IP du routeur par défaut 
option subnet-mask 255.255.255.0;
}
```
### ☀️ Test du DHCP sur node1.tp2.efrei
```
$ sudo nano /etc/sysconfig/network-scripts/ifcfg-enp0s3 
NAME=enp0s3
DEVICE=enp0s3

BOOTPROTO=DHCP
ONBOOT=yes
```
**On libère l'adresse IP**
```
$ sudo dhclient -r
```
**Résulat**
```
$ ip a
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:35:b3:81 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::a00:27ff:fe35:b381/64 scope link 
       valid_lft forever preferred_lft forever
```
**Renouvelement de l'adresse IP**
```
$ sudo dhclient
```
**Résulat**
```
$ ip a
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:35:b3:81 brd ff:ff:ff:ff:ff:ff
    inet 10.2.1.100/24 brd 10.2.1.255 scope global dynamic enp0s3
       valid_lft 3493sec preferred_lft 3493sec
    inet6 fe80::a00:27ff:fe35:b381/64 scope link 
       valid_lft forever preferred_lft forever
```
**Affichage de la table de routage**
```
$ ip r s
default via 10.2.1.254 dev enp0s3 
10.2.1.0/24 dev enp0s3 proto kernel scope link src 10.2.1.100 
192.168.56.0/24 dev enp0s8 proto kernel scope link src 192.168.56.107 metric 101
```
**Ping du DNS de Google**
```
$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=22.0 ms
```
**Ping du site web Google.fr**
```
$ ping google.fr
PING google.fr (142.250.75.227) 56(84) bytes of data.
64 bytes from par10s41-in-f3.1e100.net (142.250.75.227): icmp_seq=1 ttl=113 time=20.2 ms
```
### ☀️ BONUS
```
default-lease-time 3600;
max-lease-time 86400;
authoritative;

subnet 10.2.1.0 netmask 255.255.255.0 {
range 10.2.1.100 10.2.1.200;
option routers 10.2.1.254;
option subnet-mask 255.255.255.0;
option domain-name-servers 1.1.1.1;
}
```
**Ping du site web Google.fr**
```
$ ping google.fr
PING google.fr (142.250.75.227) 56(84) bytes of data.
64 bytes from par10s41-in-f3.1e100.net (142.250.75.227): icmp_seq=1 ttl=113 time=20.2 ms
```
### ☀️ Wireshark
![Échange DORA](echangeDORA.pcapng)

# ARP
## Tables ARP
### ☀️ Table ARP du router
```
ip neigh show
10.2.1.254 dev enp0s3 lladdr 08:00:27:9a:50:ba REACHABLE 
192.168.56.100 dev enp0s8 lladdr 08:00:27:52:c8:4d STALE 
10.2.1.253 dev enp0s3 lladdr 08:00:27:a9:4f:18 STALE 
192.168.56.1 dev enp0s8 lladdr 0a:00:27:00:00:00 REACHABLE
```
### ☀️ Echange Wireshark
![Requete ARP](requeteARP.pcapng)

## ARP Poisoning
### ☀️ Simple ARP Poisoning
```
$ sudo ip neigh change 10.2.1.254 lladdr 08:00:27:a9:4f:18 dev enp0s3
```
```
$ ip neigh show
10.2.1.254 dev enp0s3 lladdr 08:00:27:a9:4f:18 PERMANENT 
10.2.1.253 dev enp0s3 lladdr 08:00:27:a9:4f:18 STALE 
192.168.56.1 dev enp0s8 lladdr 0a:00:27:00:00:00 REACHABLE
```
