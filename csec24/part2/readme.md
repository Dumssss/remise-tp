# II. Servicer le programme

## Sommaire

- [II. Servicer le programme](#ii-servicer-le-programme)
  - [Sommaire](#sommaire)
  - [1. Création du service](#1-création-du-service)
  - [2. Tests](#2-tests)

## 1. Création du service

🌞 **Créer un service `efrei_server.service`**

- pour cela, il faut créer le fichier suivant : `/etc/systemd/system/efrei_server.service`

```bash
sudo nano /etc/systemd/system/efrei_server.service
```
- avec le contenu (simpliste) suivant :


```systemd
[Unit]
Description=Super serveur EFREI
 
[Service]
ExecStart=/home/dums/efrei_server
EnvironmentFile=/etc/systemd/system/EnvironmentFile
```

➜ **Une fois le fichier `/etc/systemd/system/efrei_server.service` créé** :

```bash
sudo systemctl daemon-reload
```

## 2. Tests

🌞 **Exécuter la commande `systemctl status efrei_server`**

```bash
$ systemctl status efrei_server
○ efrei_server.service - Super serveur EFREI
     Loaded: loaded (/etc/systemd/system/efrei_server.service; static)
     Active: inactive (dead)
```

🌞 **Démarrer le service**

```bash
sudo systemctl start efrei_server
```

➜ Vous pourrez **voir les logs du service** avec la commande 
```bash
journalctl -xe -u efrei_server
```

🌞 **Vérifier que le programme tourne correctement**

```bash 
$ systemctl status efrei_server
● efrei_server.service - Super serveur EFREI
     Loaded: loaded (/etc/systemd/system/efrei_server.service; static)
     Active: active (running) since Wed 2024-09-11 23:45:31 CEST; 4s ago
   Main PID: 1947 (app)
      Tasks: 2 (limit: 11112)
     Memory: 39.5M
        CPU: 316ms
     CGroup: /system.slice/efrei_server.service
             ├─1947 /usr/local/bin/efrei_server/app
             └─1948 /usr/local/bin/efrei_server/app

Sep 11 23:45:31 rocky systemd[1]: Started Super serveur EFREI.
```
> ➜ [**Lien vers la partie 3**](../part3/readme.md)