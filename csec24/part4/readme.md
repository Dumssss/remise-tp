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

- Bloquer toutes les connexions sortantes :
```bash
$ sudo firewall-cmd --permanent --zone=public --set-target=DROP
success
```
- Pour faire les maj temporairement :

```bash
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
```
- Et bien sur : 
```bash
$ sudo firewall-cmd --reload
success
```

- Pour bloquer toutes les connexions entrantes (y compris le ping) à part si c'est à destination du serveur SSH ou du service `efrei_admin` : 
```bash
$ sudo firewall-cmd --permanent --zone=public --set-target=DROP
$ sudo firewall-cmd --get-active-zones
drop
  interfaces: enp0s8 enp0s3
```
```bash
$ sudo firewall-cmd --permanent --zone=public --add-service=ssh
success
$ sudo firewall-cmd --permanent --zone=public --add-port=8888/tcp
success
```
```bash
$ sudo firewall-cmd --permanent --zone=public --add-icmp-block=echo-request
success
```

🌞 **Prouver que la configuration est effective**

- prouver que les connexions sortantes sont bloquées
- prouver que les pings sont bloqués, mais une connexion SSH fonctionne

![Firewall](./img/fw.jpg)

## 2. Protéger l'app contre le flood

Fail2ban notre vieil ami ! Fail2ban est un outil classique sur les OS GNU/Linux.

**Le fonctionnement de fail2ban est simpliste :**

- on lui demande de surveiller un fichier donné
- on définit un pattern à repérer dans ce fichier
- si plusieurs lignes correspondant au pattern se répètent, il effectue une action
- par exemple, on ajoute une règle firewall

> Quand on configure fail2ban pour surveiller un certain fichier, on dit qu'on crée une *jail* fail2ban.

**Cas concret ici :**

- dès qu'un client se connecte à notre service, une ligne de log est ajouté au fichier de log
- cette ligne de log contient l'IP du client qui s'est connecté
- si un client se connecte + de 5 fois en moins de 10 secondes (par exemple) on peut estimer que c'est du flood (tentative de DOS ?)
- il faudrait blacklister automatiquement l'IP de ce client dans le firewall
- fail2ban fait exactement ça

🌞 **Installer fail2ban sur la machine**

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