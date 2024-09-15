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

![Firewall](./img/fw.jpg)

## 2. Protéger l'app contre le flood

🌞 **Installer fail2ban sur la machine**
```bash
sudo dnf install epel-release
sudo dnf install fail2ban
```

🌞 **Ajouter une *jail* fail2ban**

- elle doit lire le fichier de log du service, que vous avez normalement placé dans `/var/log/`
- repérer la ligne de connexion d'un client
- blacklist à l'aide du firewall l'IP de ce client

🌞 **Vérifier que ça fonctionne !**

- faites-vous ban ! En faisant plein de connexions rapprochées avec le client
- constatez que le ban est effectif
- levez le ban (il y a une commande pour lever un ban qu'a réalisé fail2ban)

## 3. Empêcher le programme de faire des actions indésirables

Lors de son fonctionnement, un programme peut être amené à exécuter des **appels système** (ou *syscalls*) en anglais.  
Un programme **doit** exécuter un *syscall* dès qu'il veut interagir avec une ressource du système. Par exemple :

- lire/modifier un fichier
- établir une connexion réseau
- écouter sur un port
- changer les droits d'un fichier
- obtenir la liste des processus
- lancer un nouveau processus
- etc.

➜ **Exécuter un *syscall* c'est demander au kernel de faire quelque chose.**

Ainsi, par exemple, quand on exécute la commande `cat` sur un fichier pour lire son contenu, **la commande `cat` va exécuter (entre autres) le *syscall* `open` afin de pouvoir ouvrir et lire le fichier**.

> Il se passe la même chose quand genre t'utilises Discord, et t'envoies un fichier à un pote. L'application Discord va exécuter un *syscall* pour obtenir le contenu du fichier, et l'envoyer sur le réseau.

Si le programme est exécuté par **un utilisateur qui a les droits sur ce fichier, alors le kernel autorisera ce *syscall*** et le programme `cat` pourra accéder au contenu du fichier sans erreur, et l'afficher dans le terminal.

> Dit autrement : n'importe quel programme qui accède au contenu d'un fichie (par exemple) exécute **forcément** un *syscall* pour obtenir le contenu de ce fichier. Peu importe l'OS, c'est un truc commun à tous.

➜ ***seccomp* est un outil qui permet de filtrer les *syscalls* qu'a le droit d'exécuter un programme**

On définit une liste des *syscalls* que le programme a le droit de faire, les autres seront bloqués.

> Par exemple, un *syscall* sensible est `fork()` qui permet de créer un nouveau processus.

Dans notre cas, avec notre ptit *service*, c'est un des problèmes :

- vous injectez du code dans l'application en tant que vilain hacker
- pour exécuter des programmes comme `cat` ou autres
- à chaque commande exécutée avec l'injection, un *syscall* est exécuté par le programme serveur pour demander la création d'un nouveau processus (votre injection)
- on pourrait bloquer totalement ce comportement : empêcher le *service* de lancer un autre processus que `efrei_server`

🌞 **Ajouter une politique seccomp au fichier `.service`**

- la politique doit être la plus restrictive possible
- c'est à dire que juste le strict minimum des *syscalls* nécessaires doit être autorisé