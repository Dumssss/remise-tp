# Part IV : User management

**Hum, cette partie est censée être envoyée vite fait bien fait ! Prouvez-le moi :D**

Gestion d'utilisateurs, de mot de passe, et de `sudo` ! Puis dans un deuxième temps, on continue sur la gestion de permissions.

## Index

- [Part IV : User management](#part-iv--user-management)
  - [Index](#index)
  - [1. Users](#1-users)
    - [A. Master what already exists](#a-master-what-already-exists)
    - [B. User creation and configuration](#b-user-creation-and-configuration)
    - [C. Hackers gonna hack](#c-hackers-gonna-hack)
  - [2. Files and permissions](#2-files-and-permissions)
    - [A. Listing POSIX permissions](#a-listing-posix-permissions)
    - [B. Protect a file using permissions](#b-protect-a-file-using-permissions)
    - [C. Extended attributes](#c-extended-attributes)

## 1. Users

### A. Master what already exists

🌞 **Déterminer l'existant :**

- lister tous les utilisateurs créés sur la machine
```ps
[dums@node1 ~]$ awk -F':' '{ print $1}' /etc/passwd
root
bin
daemon
adm
lp
sync
shutdown
halt
mail
operator
games
ftp
nobody
tss
systemd-coredump
dbus
sssd
chrony
sshd
dums
tcpdump
```
- lister tous les groupes d'utilisateur
```ps
[dums@node1 ~]$ cat /etc/group
root:x:0:
bin:x:1:
daemon:x:2:
sys:x:3:
adm:x:4:
tty:x:5:
disk:x:6:
lp:x:7:
mem:x:8:
kmem:x:9:
wheel:x:10:dums
cdrom:x:11:
mail:x:12:
man:x:15:
dialout:x:18:
floppy:x:19:
games:x:20:
tape:x:33:
video:x:39:
ftp:x:50:
lock:x:54:
audio:x:63:
users:x:100:
nobody:x:65534:
utmp:x:22:
utempter:x:35:
ssh_keys:x:101:
tss:x:59:
input:x:999:
kvm:x:36:
render:x:998:
systemd-journal:x:190:
systemd-coredump:x:997:
dbus:x:81:
sssd:x:996:
chrony:x:995:
sshd:x:74:
sgx:x:994:
dums:x:1000:
tcpdump:x:72:
```
- déterminer la liste des groupes dans lesquels se trouvent votre utilisateur
```ps
[dums@node1 ~]$ groups dums
dums : dums wheel
```

🌞 **Lister tous les processus qui sont actuellement en cours d'exécution, lancés par `root`**
```ps
[dums@node1 ~]$ ps -u root
    PID TTY          TIME CMD
      1 ?        00:00:01 systemd
      2 ?        00:00:00 kthreadd
      3 ?        00:00:00 pool_workqueue_
      4 ?        00:00:00 kworker/R-rcu_g
.......
```

🌞 **Lister tous les processus qui sont actuellement en cours d'exécution, lancés par votre utilisateur**
```
[dums@node1 ~]$ ps -u dums
    PID TTY          TIME CMD
   1292 ?        00:00:00 systemd
   1294 ?        00:00:00 (sd-pam)
   1301 tty1     00:00:00 bash
   1332 ?        00:00:01 sshd
   1333 pts/0    00:00:00 bash
   1748 pts/0    00:00:00 ps
```

🌞 **Déterminer le hash du mot de passe de `root`**
```ps
[dums@node1 ~]$ sudo cat /etc/shadow | grep root
root:$6$rounds=100000$jdY3t.fp6mQ4a1fJ$iZ2CRYiG.ns7PZXv6fWRQAZppEssUngCI.JXmCqmHScr/fCm4t7PW.lynolXN6xt0bieMULa2D3mEvRnpKipj/:20136:0:99999:7:::
```

🌞 **Déterminer le hash du mot de passe de votre utilisateur**
```ps
[dums@node1 ~]$ sudo cat /etc/shadow | grep dums
dums:$6$vNykyiGEI17F.NWT$53An2NFBRuTlh0YfvGWn4l0dKjry6NWU1BN1wy9.MWhtexFWZNGvpWENHjqC81dOpsdv8DlLigvNTY3VI4vbn/::0:99999:7:::
```

🌞 **Déterminer la fonction de hachage qui a été utilisée**
```ps
[dums@node1 ~]$ sudo passwd -S root && sudo passwd -S dums
root PS 2025-02-17 0 99999 7 -1 (Password set, SHA512 crypt.)
dums PS 1969-12-31 0 99999 7 -1 (Password set, SHA512 crypt.)
```

🌞 **Déterminer, pour l'utilisateur `root`** :

- son shell par défaut
```ps
- le chemin vers son répertoire personnel
[dums@node1 ~]$ grep '^root' /etc/passwd
root:x:0:0:root:/root:/bin/bash
```

🌞 **Déterminer, pour votre utilisateur** :

- son shell par défaut
- le chemin vers son répertoire personnel
```ps
[dums@node1 ~]$ grep '^dums' /etc/passwd
dums:x:1000:1000:Clement:/home/dums:/bin/bash
```

🌞 **Afficher la ligne de configuration du fichier `sudoers` qui permet à votre utilisateur d'utiliser `sudo`**
```ps
[dums@node1 ~]$ sudo grep '%wheel' /etc/sudoers
%wheel  ALL=(ALL)       ALL
```

### B. User creation and configuration

🌞 **Créer un utilisateur :**

- doit s'appeler `meow`
- ne doit appartenir QUE à un groupe nommé `admins`
- ne doit pas avoir de répertoire personnel utilisable
- ne doit pas avoir un shell utilisable
```ps
[dums@node1 ~]$ sudo groupadd admins
[dums@node1 ~]$ sudo useradd -g admins -M -s /sbin/nologin meow
```

> Il s'agit donc ici d'un utilisateur avec lequel on pourra pas se connecter à la machine (ni en console, ni en SSH).

🌞 **Configuration `sudoers`**

- ajouter une configuration `sudoers` pour que l'utilisateur `meow` puisse exécuter seulement et uniquement les commandes `ls`, `cat`, `less` et `more` en tant que votre utilisateur
```ps
[dums@node1 ~]$ sudo visudo
meow    ALL=(dums) /usr/bin/ls, /usr/bin/cat, /usr/bin/less, /usr/bin/more
```
- ajouter une configuration `sudoers` pour que les membres du groupe `admins` puisse exécuter seulement et uniquement la commande `apt` en tant que `root`
```ps
[dums@node1 ~]$ sudo visudo
%admins ALL=(root) /bin/dnf
```
- ajouter une configuration `sudoers` pour que votre utilisateur puisse exécuter n'importe quelle commande en tant `root`, sans avoir besoin de saisir un mot de passe
```ps
[dums@node1 ~]$ sudo visudo
dums ALL=(root) NOPASSWD: ALL
```

- prouvez que ces 3 configurations ont pris effet (vous devez vous authentifier avec le bon utilisateur, et faire une commande `sudo` qui doit fonctioner correctement)
```ps
[dums@node1 ~]$ sudo su -s /bin/bash - meow
Last login: Tue Feb 18 15:34:32 CET 2025 on pts/0
su: warning: cannot change directory to /home/meow: No such file or directory
[meow@node1 dums]$ sudo -l

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for meow:
Matching Defaults entries for meow on node1:
    !visiblepw, always_set_home, match_group_by_gid, always_query_group_plugin, env_reset, env_keep="COLORS DISPLAY HOSTNAME HISTSIZE
    KDEDIR LS_COLORS", env_keep+="MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE", env_keep+="LC_COLLATE LC_IDENTIFICATION
    LC_MEASUREMENT LC_MESSAGES", env_keep+="LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE", env_keep+="LC_TIME LC_ALL LANGUAGE
    LINGUAS _XKB_CHARSET XAUTHORITY", secure_path=/sbin\:/bin\:/usr/sbin\:/usr/bin

User meow may run the following commands on node1:
    (root) /bin/apt
    (dums) /bin/ls, /bin/cat, /bin/less, /bin/more
[meow@node1 dums]$ sudo -u dums /bin/ls
bigfile
```
```ps
[dums@node1 ~]$ sudo -l
Matching Defaults entries for dums on node1:
    !visiblepw, always_set_home, match_group_by_gid, always_query_group_plugin, env_reset, env_keep="COLORS DISPLAY HOSTNAME HISTSIZE
    KDEDIR LS_COLORS", env_keep+="MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE", env_keep+="LC_COLLATE LC_IDENTIFICATION
    LC_MEASUREMENT LC_MESSAGES", env_keep+="LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE", env_keep+="LC_TIME LC_ALL LANGUAGE
    LINGUAS _XKB_CHARSET XAUTHORITY", secure_path=/sbin\:/bin\:/usr/sbin\:/usr/bin

User dums may run the following commands on node1:
    (ALL) ALL
    (root) NOPASSWD: ALL
```

### C. Hackers gonna hack

🌞 **Déjà une configuration faible ?**

- l'utilisateur `meow` est en réalité complètement `root` sur la machine hein là. Prouvez-le.
```ps
[dums@node1 ~]$ sudo su -s /bin/bash - meow
[meow@node1 dums]$ sudo -u dums less /etc/profile
[sudo] password for meow:
!/bin/bash
[dums@node1 ~]$ su root
Password:
[root@node1 dums]# whoami
root
```
- proposez une configuration similaire, sans présenter cette faiblesse de configuration
  - vous pouvez ajouter de la configuration
  - ou supprimer de la configuration
  - du moment qu'on garde des fonctionnalités à peu près équivalentes !

```ps
[dums@node1 ~]$ sudo nano /etc/pam.d/su
# Uncomment the following line to require a user to be in the "wheel" group.
auth            required        pam_wheel.so use_uid
[dums@node1 ~]$ sudo usermod -aG wheel dums
```

## 2. Files and permissions

**Dans un OS, en particulier Linux, on dit souvent que "tout est fichier".**

En effet, que ce soit les programmes (que ce soit `ls`, ou Firefox, ou Steam, ou le kernel), les fichiers personnels, les fichiers de configuration, et bien d'autres, **l'ensemble des composants d'un OS, et tout ce qu'on peut y ajouter se résume à un gros tas de fichiers.**

Gérer correctement les permissions des fichiers est une étape essentielle dans le renforcement d'une machine.

**C'est la première barrière de sécurité, (beaucoup) trop souvent négligée, alors qu'elle est extrêmement efficace et robuste.**

### A. Listing POSIX permissions

🌞 **Déterminer les permissions des fichiers/dossiers...**

- le fichier qui contient la liste des utilisateurs
- le fichier qui contient la liste des hashes des mots de passe des utilisateurs
- le fichier de configuration du serveur OpenSSH
- le répertoire personnel de l'utilisateur `root`
- le répertoire personnel de votre utilisateur
- le programme `ls`
- le programme `systemctl`

> POSIX c'est le nom d'un standard qui regroupe plein de concepts avec lesquels vous êtes finalement déjà familiers. Les permissions rwx qu'on retrouve sous les OS Linux (et MacOS, et BSD, et d'autres) font partie de ce standard et sont donc appelées "permissions POSIX".

![Windows POSIX](./img/posix_compliant.png)

### B. Protect a file using permissions

🌞 **Restreindre l'accès à un fichier personnel**

- créer un fichier nommé `dont_readme.txt` (avec le contenu de votre choix)
- il doit se trouver dans un dossier lisible et écrivable par tout le monde
- faites en sorte que seul votre utilisateur (pas votre groupe) puisse lire ou modifier ce fichier
- personne ne doit pouvoir l'exécuter
- prouvez que :
  - votre utilisateur peut le lire
  - votre utilisateur peut le modifier
  - l'utilisateur `meow` ne peut pas y toucher
  - l'utilisateur `root` peut quand même y toucher

> C'est l'un des "superpouvoirs" de `root` : contourner les permissions POSIX (les permissions `rwx`). On verra bien assez tôt que `root` n'a pas de "superpouvoirs" mais que ces contournements sont liés à une mécanique qu'on appelle les *capabilites*. C'est pour plus tard ! :)

### C. Extended attributes

🌞 **Lister tous les programmes qui ont le bit SUID activé**

🌞 **Rendre le fichier `dont_readme.txt` immuable**

- ça se fait avec les attributs étendus
- "immuable" ça veut dire qu'il ne peut plus être modifié DU TOUT : il est donc en read-only
- prouvez que le fichier ne peut plus être modifié par **personne**
