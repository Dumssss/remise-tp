# III. MAKE SERVICES GREAT AGAIN

## Sommaire

- [III. MAKE SERVICES GREAT AGAIN](#iii-make-services-great-again)
  - [Sommaire](#sommaire)
  - [1. Restart automatique](#1-restart-automatique)
  - [2. Utilisateur applicatif](#2-utilisateur-applicatif)
  - [3. Maîtrisez l'emplacement des fichiers](#3-maîtrisez-lemplacement-des-fichiers)
  - [4. Security hardening](#4-security-hardening)

## 1. Restart automatique

🌞 **Ajoutez une clause dans le fichier `efrei_server.service` pour le restart automatique**

```bash
restart=always
```

🌞 **Testez que ça fonctionne**

- lancez le *service* avec une commande `systemctl`:
```bash
sudo systemctl start efrei_server.server
```
- affichez le processus lancé par *systemd* avec une commande `ps`
 ```bash
[dums@rocky efrei_server]$ ps aux | grep efrei_server
root        2291  1.6  0.1   2956  2132 ?        Ss   00:57   0:00 /usr/local/bin/efrei_server/app
root        2292  1.6  1.4  31244 25856 ?        S    00:57   0:00 /usr/local/bin/efrei_server/app
dums        2296  0.0  0.1   3880  2176 pts/0    S+   00:57   0:00 grep --color=auto efrei_server

[dums@rocky efrei_server]$ sudo kill -9 2291 2292

[dums@rocky efrei_server]$ systemctl status efrei_server
● efrei_server.service - Super serveur EFREI
     Loaded: loaded (/etc/systemd/system/efrei_server.service; static)
     Active: active (running) since Thu 2024-09-12 00:58:28 CEST; 6s ago
   Main PID: 2301 (app)
      Tasks: 2 (limit: 11112)
     Memory: 32.5M
        CPU: 438ms
     CGroup: /system.slice/efrei_server.service
             ├─2301 /usr/local/bin/efrei_server/app
             └─2302 /usr/local/bin/efrei_server/app

Sep 12 00:58:28 rocky systemd[1]: Started Super serveur EFREI.
```
## 2. Utilisateur applicatif

Lorsqu'un programme s'exécute sur une machine (peu importe l'OS ou le contexte), le programme est **toujours** exécuté sous l'identité d'un utilisateur.  
Ainsi, pendant son exécution, le programme aura les droits de cet utilisateur.  

> Par exemple, un programme lancé en tant que `toto` pourra lire un fichier `/var/log/toto.log` uniquement si l'utilisateur `toto` a les droits sur ce fichier.

🌞 **Créer un utilisateur applicatif**

```bash
$ sudo useradd -r -d /usr/local/bin/efrei_server/ -s /usr/sbin/nologin efreiuser
```

🌞 **Modifier le service pour que ce nouvel utilisateur lance le programme `efrei_server`**

```bash
[Unit]
Description=Super serveur EFREI

[Service]
ExecStart=/usr/local/bin/efrei_server/app
EnvironmentFile=/usr/local/bin/efrei_server/env
Restart=always
User=efreiuser
```

🌞 **Vérifier que le programme s'exécute bien sous l'identité de ce nouvel utilisateur**

```bash
$ ps aux | grep efrei_server
efreius+    2734  7.6  0.1   2956  2136 ?        Ss   03:02   0:00 /usr/local/bin/efrei_server/app
efreius+    2735  1.7  1.4  31244 25856 ?        S    03:02   0:00 /usr/local/bin/efrei_server/app
```

> *Déjà à ce stade, le programme a des droits vraiment limités sur le système.*

## 3. Maîtrisez l'emplacement des fichiers

🌞 **Choisir l'emplacement du fichier de logs**

- créez un dossier dédié dans `/var/log/` (le dossier standard pour stocker les logs) 
```bash
sudo mkdir /var/log/efrei_serverlog 
```
- indiquez votre nouveau dossier de log à l'application avec la variable `LOG_DIR`
```bash
LOG_DIR=/var/log/efrei_serverlog 
```
- l'application créera un fichier `server.log` à l'intérieur

🌞 **Maîtriser les permissions du fichier de logs**

Droit sur le fichier ``server.log``
```bash
[dums@rocky efrei_serverlog]$ sudo chmod 600 server.log
[dums@rocky efrei_serverlog]$ ls -al
-rw-------. 1 efreiuser efreiuser   58 Sep 12 03:19 server.log
```

Propriété unique de l'utilisateur `efreiuser` :
```bash
[dums@rocky log]$ sudo chmod 700 efrei_serverlog/
[dums@rocky log]$ ls -al
drwx------.  2 efreiuser efreiuser     24 Sep 12 03:19 efrei_serverlog
```

## 4. Security hardening

 **Config finale :**

```bash
[Unit]
Description=Super serveur EFREI

[Service]
ExecStart=/usr/local/bin/efrei_server/app
EnvironmentFile=/usr/local/bin/efrei_server/env
Restart=always
User=efreiuser
RemoveIPC=yes
NoNewPrivileges=yes
ProtectKernelLogs=yes
ProtectControlGroups=yes
ProtectHome=yes
SystemCallFilter=~@raw.io
SystemCallFilter=~@resources
SystemCallFilter=~@obsolete
SystemCallFilter=~@mount
SystemCallFilter=~@debug
SystemCallFilter=~@cpu-emulation
SystemCallFilter=~@privileged
UMask=0077
ProtectClock=yes
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_NET_ADMIN
ProtectKernelModules=yes
SystemCallArchitectures=native
MemoryDenyWriteExecute=yes
RestrictNamespaces=yes
ProtectHostname=yes
ProtectKernelTunables=yes
RestrictRealtime=yes
LockPersonality=yes
ProtectProc=readonly
ProcSubset=pid
```

**Score de sécurité**
```bash
[dums@rocky ~]$ systemd-analyze security | grep efrei_server
efrei_server.service      2.9 OK        🙂
```
> ➜ [**Lien vers la partie 4**](../part4/readme.md)