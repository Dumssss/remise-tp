# Prologue
### I. Setup GNS3
**On configure les machines comme suit :**
```
$ sudo nano /etc/sysconfig/network-scripts/ifcfg-enp0s8
NAME=enp0s3, enp0s8 ou enp0s9
DEVICE=enp0s3, enp0s8 ou enp0s9

BOOTPROTO=static
ONBOOT=yes

IPADDR=ip Réseau 1, réseau 2 ou réseau 3
NETMASK=255.255.255.0 ou 255.255.255.254 pour le réseau 3
```
### II. Routes routes routes
**🌞 Activer le routage sur les deux machines router**

**Sur le router 1 et 2**
```
$ sudo sysctl -w net.ipv4.ip_forward=1
$ sudo firewall-cmd --add-masquerade
$ sudo firewall-cmd --add-masquerade --permanent
```
**🌞 Mettre en place les routes locales**
```
$ cat /etc/sysconfig/network-scripts/route-enp0s8 
10.3.2.0/24 via 10.3.100.2
$ sudo ip route add 10.3.2.0/24 via 10.3.100.2 dev enp0s8
```
```
$ sudo ip route add 10.3.1.0/24 via 10.3.100.1 dev enp0s3

$ sudo cat /etc/sysconfig/network-scripts/route-enp0s3
10.3.1.0/24 via 10.3.100.1

$ ping 10.3.2.11
PING 10.3.2.11 (10.3.2.11) 56(84) bytes of data.
64 bytes from 10.3.2.11: icmp_seq=1 ttl=64 time=1.38 ms
```
**🌞 Mettre en place les routes par défaut**
```
$ echo 'GATEWAY=10.3.1.254' | sudo tee /etc/sysconfig/network
$ echo 'GATEWAY=10.3.1.254' | sudo tee /etc/sysconfig/network
$ echo 'GATEWAY=10.3.2.254' | sudo tee /etc/sysconfig/network
$ echo 'GATEWAY=10.3.2.254' | sudo tee /etc/sysconfig/network
$ echo 'GATEWAY=10.3.100.1' | sudo tee /etc/sysconfig/network
```
**Depuis node1.net1.tp3**
```
$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=6 ttl=113 time=17.2 ms
```
```
$ traceroute 1.1.1.1
traceroute to 1.1.1.1 (1.1.1.1), 30 hops max, 60 byte packets
 1  * * *
 2  192.168.122.1 (192.168.122.1)  1.232 ms  1.193 ms  1.430 ms
 3  10.100.0.1 (10.100.0.1)  6.530 ms  6.494 ms  6.459 ms
 4  10.100.255.11 (10.100.255.11)  5.474 ms  5.433 ms  5.183 ms
 5  185.176.176.10 (185.176.176.10)  23.785 ms  23.741 ms  23.622 ms
 6  100.126.127.254 (100.126.127.254)  18.039 ms  17.725 ms  17.682 ms
 7  100.126.127.253 (100.126.127.253)  16.172 ms  14.681 ms  14.629 ms
 8  185.181.155.200 (185.181.155.200)  14.796 ms  17.744 ms  17.698 ms
 9  linktsas-ic-381495.ip.twelve99-cust.net (62.115.186.121)  17.659 ms  18.032 ms  16.854 ms
10  prs-b1-link.ip.twelve99.net (62.115.186.86)  16.807 ms prs-b9-link.ip.twelve99.net (62.115.186.120)  16.772 ms  15.291 ms
11  cloudflare-ic-375100.ip.twelve99-cust.net (80.239.194.103)  15.426 ms prs-b1-link.ip.twelve99.net (62.115.115.88)  19.741 ms  18.157 ms
12  cloudflare-ic-363840.ip.twelve99-cust.net (213.248.73.69)  18.101 ms cloudflare-ic-375100.ip.twelve99-cust.net (80.239.194.103)  52.670 ms 172.71.128.2 (172.71.128.2) 
20.049 ms
13  172.71.116.2 (172.71.116.2)  37.892 ms one.one.one.one (1.1.1.1)  19.711 ms 172.71.132.2 (172.71.132.2)  19.592 ms
```

# I. Serveur DHCP
### I. Setup ```dhcp.net1.tp3```
```
$ sudo ip route add default via 10.3.1.254 dev enp0s3
$ sudo dnf install -y dhcp-server
```
```
$ sudo cat /etc/dhcp/dhcpd.conf

default-lease-time 3600;
max-lease-time 86400;
authoritative;

subnet 10.3.1.0 netmask 255.255.255.0 {
range 10.3.1.50 10.3.1.99;
option subnet-mask 255.255.255.0;
option routers 10.3.1.254;
option domain-name-servers 1.1.1.1;
}
```
🌞 **Preuve**
```
$ ip a
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:da:11:76 brd ff:ff:ff:ff:ff:ff
    inet 10.3.1.50/24 brd 10.3.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 3515sec preferred_lft 3515sec
    inet6 fe80::a00:27ff:feda:1176/64 scope link 
       valid_lft forever preferred_lft forever
```
```
$ ip r s
default via 10.3.1.254 dev enp0s3 proto dhcp src 10.3.1.50 metric 100 
10.3.1.0/24 dev enp0s3 proto kernel scope link src 10.3.1.50 metric 100 
192.168.56.0/24 dev enp0s8 proto kernel scope link src 192.168.56.2 metric 101 
```
```
$ nmcli dev show | grep 'IP4.DNS'
IP4.DNS[1]: 1.1.1.1
```

# II. Serveur WEB
### I. Installation
🌞 **Installation du serveur web NGINX**
```
$ sudo dnf install -y nginx
```
### 2. Page HTML et Racine WEB
**Création d'une bête page HTML**
```
$ sudo mkdir /var/www/efrei_site_nul
$ sudo chown nginx:nginx efrei_site_nul/
$ touch /var/www/efrei_site_nul/index.html && nano /var/www/efrei_site_nul/index.html
Ferrari c'est la meilleure marque de voiture y'a pas de débat
```
### 3. Config de NGINX
**🌞 Création d'un fichier de configuration NGINX**
```
$ sudo touch /etc/nginx/conf.d/web.net2.tp3.conf && sudo nano /etc/nginx/conf.d/web.net2.tp3.conf
```
```
  server {
      server_name   web.net2.tp3;
      listen        10.3.2.101:80;

      location      / {
          root      /var/www/efrei_site_nul;
          index index.html;
      }
  }
```
### 4. Firewall
**🌞 Ouvrir le port nécessaire dans le firewall**
```
$ sudo firewall-cmd --add-port=80/tcp --permanent
```
```
$ sudo firewall-cmd --reload
```
```
$ sudo firewall-cmd --list-all
$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 80/tcp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```
### 5. Test
**🌞 Démarrez le service NGINX !**
```
$ sudo systemctl start nginx
$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.

$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: disabled)
     Active: active (running) since Sat 2023-10-07 16:46:28 CEST; 46s ago
   Main PID: 11709 (nginx)
      Tasks: 2 (limit: 4611)
     Memory: 2.0M
        CPU: 13ms
     CGroup: /system.slice/nginx.service
             ├─11709 "nginx: master process /usr/sbin/nginx"
             └─11710 "nginx: worker process"
```
**🌞 Test local**
```
$ curl http://10.3.2.101
Ferrari c'est la meilleure marque de voiture y'a pas de débat
```
**🌞 Accéder au site web depuis un client**

Avec interface graphique, on arrive sur une page blanche avec écrit  : 
```
Ferrari c'est la meilleure marque de voiture y'a pas de débat
```
Ce qui par ailleurs, est vrai, mais ça c'est un autre sujet.
**🌞 Avec un nom ?**
```
$ sudo cat /etc/hosts 
10.3.2.101 web.net2.tp3
```
```
$ curl http://web.net2.tp3
Ferrari c'est la meilleure marque de voiture y'a pas de débat
```
C'est pas moi qui le dis...

# III. Serveur DNS
### 1. Install
```
$ sudo dnf update -y
$ sudo dnf install -y bind bind-utils
```
### 2. Install
```
$ sudo cat /etc/named.conf
options {
        listen-on port 53 { 127.0.0.1; any; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        allow-query     { localhost; any; };
        allow-query-cache { localhost; any; };

        recursion yes; # cette ligne autorise la recursion, voir la note en dessous de cette conf
[...]
zone "net2.tp3" IN {
     type master;
     file "net2.tp3.db";
     allow-update { none; };
     allow-query {any; };
};
zone "2.3.10.in-addr.arpa" IN {
     type master;
     file "net2.tp3.rev";
     allow-update { none; };
     allow-query { any; };
};
```
**➜ Et pour les fichiers de zone**
```
$ sudo cat /var/named/net2.tp3.db
$TTL 86400
@ IN SOA dns.net2.tp3. admin.net2.tp3. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)
@ IN NS dns.net2.tp3.
dns        IN A 10.3.2.102
web        IN A 10.3.2.101

```
```
$ sudo cat /var/named/net2.tp3.rev

$TTL 86400
@ IN SOA dns.net2.tp3. admin.net2.tp3. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)

; Infos sur le serveur DNS lui même (NS = NameServer)
@ IN NS dns.net2.tp3.
102   IN PTR dns.net2.tp3.
101   IN PTR web.net2.tp3.
```
**➜ Une fois ces 3 fichiers en place, on démarre le service DNS**
```
$ sudo systemctl start named
$ sudo systemctl enable named
$ sudo systemctl status named
$ sudo journalctl -xe -u named
```
### 3. Firewall
**🌞 Ouvrir le port nécessaire dans le firewall**
```
$ sudo firewall-cmd --add-port=53/udp --permanent
success
```
```
$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 53/udp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```
### 4. Test
**🌞 Depuis l'une des machines clientes du réseau 1 (par exemple node1.net1.tp3)**
```
$ dig web.net2.tp3 @10.3.2.102

; <<>> DiG 9.16.23-RH <<>> web.net2.tp3 @10.3.2.102
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 27675
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 8cc46a6c44559fcd010000006522f2b99e5bbf2169ff777f (good)
;; QUESTION SECTION:
;web.net2.tp3.			IN	A

;; ANSWER SECTION:
web.net2.tp3.		86400	IN	A	10.3.2.101

;; Query time: 2 msec
;; SERVER: 10.3.2.102#53(10.3.2.102)
;; WHEN: Sun Oct 08 20:19:37 CEST 2023
;; MSG SIZE  rcvd: 85
```
```
$ curl web.net2.tp3
Ferrari c'est la meilleure marque de voiture y'a pas de débat
```
_C'est encore écrit_

### 5. DHCP my old friend
**🌞 Editez la configuration du serveur DHCP sur ```dhcp.net1.tp3```**
```
$ sudo cat /etc/dhcp/dhcpd.conf
default-lease-time 3600;
max-lease-time 86400;
authoritative;

subnet 10.3.1.0 netmask 255.255.255.0 {
range 10.3.1.50 10.3.1.99;
option subnet-mask 255.255.255.0;
option routers 10.3.1.254;
option domain-name-servers 10.3.2.102;
}
```
```
$ nmcli dev show | grep 'IP4.DNS'
IP4.DNS[1]:                             10.3.2.102
```
```
$ dig web.net2.tp3
; <<>> DiG 9.16.23-RH <<>> web.net2.tp3
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 38967
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 86415b795fb36eae010000006522f5ac049e9a8b87b6d3bd (good)
;; QUESTION SECTION:
;web.net2.tp3.			IN	A

;; ANSWER SECTION:
web.net2.tp3.		86400	IN	A	10.3.2.101

;; Query time: 1 msec
;; SERVER: 10.3.2.102#53(10.3.2.102)
;; WHEN: Sun Oct 08 20:32:13 CEST 2023
;; MSG SIZE  rcvd: 85
```
