# TP1 : Containers

## I. Docker
### 1. Install

🌞 **Installer Docker sur la machine**  
Installation du service :

```
$ sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
Démarrage du service :
```
$ sudo systemctl start docker
```
Ajout de mon utilisateur au groupe docker :
```
$ sudo usermod -aG docker $(whoami)
```
### 3. Lancement de conteneurs
🌞 **Utiliser la commande docker run**  
Lancement du conteneur ```NGINX```
```
$ docker run --name web -v /home/admin/tp_docker/nginx/test.conf:/etc/nginx/conf.d/test.conf -v /home/admin/tp_docker/nginx/index.html:/usr/share/nginx/html/index.html -p 8888:80 --memory=512m --cpus=0.5 -d nginx
```
Contenu de ```test.conf``` :
```
$ cat /home/admin/tp_docker/nginx/test.conf
server {
  listen 9999;
  root /var/www/tp_docker;
}
```
## II. Images
### 2. Construisez votre propre Dockerfile
🌞 **Construire votre propre image**
```
$ cat dockerfile
FROM ubuntu:latest

RUN apt update -y

RUN apt install -y apache2

RUN echo "Clement est le plus beau." > /var/www/html/index.html

COPY apache2.conf /etc/apache2/apache2.conf

CMD ["apache2","-D", "FOREGROUND"]
```
La conf d'apache2 :
```
$ cat apache2.conf
Listen 80

LoadModule mpm_event_module "/usr/lib/apache2/modules/mod_mpm_event.so"
LoadModule dir_module "/usr/lib/apache2/modules/mod_dir.so"
LoadModule authz_core_module "/usr/lib/apache2/modules/mod_authz_core.so"

DirectoryIndex index.html
DocumentRoot "/var/www/html/"

ErrorLog "/var/log/apache2/error.log"
LogLevel warn
```
Le docker file :
```
$ docker build . -t mydockerfile
[+] Building 2.3s (10/10) FINISHED
[...]
```
```
$ docker run -d -p 8888:80 mydockerfile
0f5b26e93ad7205dcb1527b48cc22365cb6db28205feaf5396bad2eaa5611e17
```
```
$ curl localhost:8888
 Clement est le plus beau.
$ curl 192.168.1.25:8888
 Clement est le plus beau.
```