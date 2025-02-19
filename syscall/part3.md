# Part III : Service Hardening



➜ **Le mécanisme du kernel Linux qui permet de filter les *syscalls*  que fait un programme s'appelle `seccomp`.**

On utilise donc un profil `seccomp` pour filtrer ce qu'a le droit de faire un processus ou non.

Chaque processus lancé peut être lancé avec une whitelist des *syscalls* qu'il a le droit d'appeler.

Tout autre appel sera bloqué.

➜ **On va utiliser le classique serveur Web NGINX dans cette partie comme exemple !**

Un bon cas d'école, et loin d'être inutile tellement NGINX est partout aujourd'hui :)

➜ Avec **systemd** (le gestionnaire de services de Linux), **il est aisé d'appliquer un profil `seccomp` à un service.**

En ajoutant une clause `SystemCallFilter=` à la définition du service, on peut lister les *syscalls* qu'un service aura le droit d'effectuer.


## 1. Install NGINX

➜ **Installer et démarrer le serveur Web NGINX sur la machine**

- le paquet s'appelle `nginx` sous Rocky
- démarrer le service, ouvrez le port firewall, visitez le site web
- assurez-vous que ça marche correctement quoi
- **puis stoppez le service**

➜ **Visualiser la définition du service NGINX**

- chaque service Linux est défini dans un fichier `.service`
- vous pouvez afficher le chemin et le contenu du fichier associé à un service avec `systemctl cat` :

```bash
sudo systemctl cat nginx
```

> Soyez attentif un peu à son contenu, il faudra écrire par vous-mêmes un service à la partie suivante. Il sera bon de s'inspirer de celui-ci !

➜ **La ligne la plus importante du fichier, c'est celle qui commence par `ExecStart=`**.

- c'est la commande qui est lancée quand vous faites un `sudo systemctl start nginx`
- **autrement dit, lancer cette commande à la main, c'est lancer le programme NGINX à la main**, sans passer par le service
- pourquoi faire ça ? Well...

## 2. NGINX Tracing

🌞 **Tracer l'exécution du programme NGINX**

- lancer NGINX à la main, et utilisez `strace` ou `sysdig` pour voir tous les appels systèmes qu'il effectue
```ps
[dums@vbox ~]$ sudo sysdig -w nginx.scap "proc.name=nginx"
```

- visitez la page web d'accueil pendant que vous tracez l'exécution, pour voir les *syscalls*  nécessaires lors d'un fonctionnement normal
- dans le compte-rendu, listez tous les *syscalls*  passés par NGINX

Suite --> [Fichier curl.scap](./nginx.scap)

## 3. NGINX Hardening

🌞 **HARDEN**

- modifier le fichier `nginx.service` pour inclure un filtrage des *syscalls*
- principe du moindre privilège : vous n'autorisez que le strict nécessaire
- vous me remettez le fichier `nginx.service` modifié dans le compte-rendu naturellement !

Suite --> [Fichier curl.scap](./nginx.service)