# Part VI : Webserver and Reverse proxy

**Le serveur Web, un classique de l'administration Linux**.

Ici on va ajouter NGINX comme reverse proxy devant notre application Web. Il faudra un deuxième VM pour cette section :

- la première VM utilitsée jusqu'ici portera la serveur web
- la deuxième VM agira comme reverse proxy

## Index

- [Part VI : Webserver and Reverse proxy](#part-vi--webserver-and-reverse-proxy)
  - [Index](#index)
  - [1. Webserver](#1-webserver)
  - [2. Reverse proxy](#2-reverse-proxy)
  - [3. HTTPS](#3-https)
  - [4. Bonus : dear TLS](#4-bonus--dear-tls)

## 1. Webserver

> Toute cette section est à réaiser sur une seule des deux VMs

🌞 **Installer NGINX**

```ps
sudo dnf install -y nginx
sudo systemctl enable --now nginx
sudo systemctl status nginx
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --reload
```

🌞 **Prouver que le serveur Web est fonctionnel**

```ps
[dums@node1 ~]$ curl http://10.1.1.11
<!doctype html>
<html>
  <head>

  ...
```

🌞 **Créer un nouveau site web**

- créez un nouveau dossier dans `/var/www/` et appelez le `super_site`
```ps
[dums@node1 ~]$ sudo mkdir /var/www/super_site
```
- créez un simple fichier `index.html` à l'intérieur avec le contenu de votre choix
```ps
[dums@node1 ~]$ sudo nano /var/www/super_site/index.html
```
- il doit respecter le principe du moindre privilège :
```ps
[dums@node1 ~]$ sudo useradd -r -s /sbin/nologin webuser
[dums@node1 ~]$ sudo chown -R webuser:webuser /var/www/super_site
[dums@node1 ~]$ sudo chmod -R 755 /var/www/super_site
[dums@node1 ~]$ sudo chmod 644 /var/www/super_site/index.html
```
- ajustez la configuration de NGINX pour qu'il serve ce nouveau site web
```ps
[dums@node1 ~]$ sudo tee /etc/nginx/conf.d/super_site.conf > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    root /var/www/super_site;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
```
- supprimez la configuration qui concerne le site par défaut de NGINX
```ps
sudo rm -f /etc/nginx/conf.d/default.conf
```

🌞 **Prouvez que le nouveau site web peut être visité**

```ps
[dums@node1 ~]$ curl http://10.1.1.11
<h1>Bienvenue sur mon super site !</h1>
```

## 2. Reverse proxy

> Pour cette partie, passez sur une deuxième VM fraîchement clonée. Vous pouvez dérouler votre script développé à la partie précédente.

🌞 **Installer NGINX**

```ps
sudo dnf install -y nginx
sudo systemctl enable --now nginx
sudo systemctl status nginx
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --reload
```

🌞 **Proposer une configuration minimale**

Voilà la conf -> [nginx.conf](./nginx.conf)

```ps
[dums@vbox ~]$ sudo rm /etc/nginx/nginx.conf
[dums@vbox ~]$ sudo nano /etc/nginx/nginx.conf
[dums@vbox ~]$ sudo systemctl restart nginx
[dums@vbox ~]$ curl http://10.1.1.12
<h1>Bienvenue sur mon super site !</h1>
[dums@vbox ~]$
```

## 3. HTTPS

Enfin, on propose **du chiffrement au client.**

On reste sur la machine reverse proxy ici.

🌞 **Générer une clé et un certificat auto-signé**

 - `/etc/pki/tls/private/` pour les clés privées
 - `/etc/pki/tls/certs/` pour les certificats.
```ps
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt
```

🌞 **Ajuster la configuration du reverse proxy**

```ps
[dums@vbox nginx]$ curl -k https://10.1.1.12
<h1>Bienvenue sur mon super site !</h1>
```
```ps
[dums@vbox nginx]$ sudo ss -tlnp | grep 443
LISTEN 0      511          0.0.0.0:443       0.0.0.0:*    users:(("nginx",pid=5577,fd=7),("nginx",pid=5576,fd=7))
```