
# Part II : Observe 
## Sommaire

- [Part II : Observe](#part-ii--observe)
  - [Sommaire](#sommaire)
  - [1. strace](#1-strace)
  - [2. sysdig](#2-sysdig)
    - [A. Intro](#a-intro)
    - [B. Use it](#b-use-it)
  - [3. Bonus : Stratoshark](#3-bonus--stratoshark)

## 1. strace

Si on veut tracer un processus avec `strace`, c'est comme ça :

```bash
# pour tracer l'exécution d'un echo par exemple
$ strace echo yo
```

🌞 **Utiliser `strace` pour tracer l'exécution de la commande `ls`**

- faites `ls` sur un dossier qui contient des trucs
- mettez en évidence le *syscall* pour écrire dans le terminal le résultat du `ls`
```ps
[dums@vbox ~]$ strace ls /home/dums
write(1, "timeless.mp3\nwget-log\n", 22) = 22
```

🌞 **Utiliser `strace` pour tracer l'exécution de la commande `cat`**

- faites `cat` sur un fichier qui contient des trucs
- mettez en évidence le *syscall* qui demande l'ouverture du fichier en lecture
- mettez en évidence le *syscall* qui écrit le contenu du fichier dans le terminal
```ps
[dums@vbox ~]$ strace cat coucou
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
write(1, "ta gueule\n", 10ta gueule
)             = 10
```

🌞 **Utiliser `strace` pour tracer l'exécution de `curl example.org`**

- vous devez utiliser une option de `strace`
- elle affiche juste un tableau qui liste tous les *syscalls*  appelés par la commande tracée, et combien de fois ils ont été appelé
```ps
[dums@vbox ~]$ strace -c curl example.org

... 

% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 47.28    0.003615         225        16           poll
 12.84    0.000982         982         1         1 connect
 11.39    0.000871         871         1           sendto
  6.24    0.000477           3       141           mmap
  4.79    0.000366           6        54           close
  4.55    0.000348           9        35           mprotect
  2.90    0.000222           3        60        14 openat
  1.95    0.000149           6        24           futex
  1.79    0.000137          19         7           write
  1.65    0.000126          63         2           socketpair
  0.82    0.000063           1        53           rt_sigaction
  0.72    0.000055           1        36           read
  0.60    0.000046           1        46           fstat
  0.55    0.000042          42         1           recvfrom
  0.37    0.000028          14         2           socket
  0.22    0.000017           4         4           setsockopt
  0.18    0.000014          14         1           clone3
  0.13    0.000010           5         2           statfs
  0.12    0.000009           2         4           brk
  0.12    0.000009           4         2         1 access
  0.12    0.000009           9         1           getsockopt
  0.12    0.000009           1         6           fcntl
  0.09    0.000007           7         1           munmap
  0.09    0.000007           7         1           pipe
  0.08    0.000006           3         2           getdents64
  0.08    0.000006           3         2           newfstatat
  0.05    0.000004           4         1           getsockname
  0.05    0.000004           4         1           getpeername
  0.03    0.000002           1         2           ioctl
  0.03    0.000002           1         2         1 arch_prctl
  0.03    0.000002           2         1           getrandom
  0.01    0.000001           1         1           sysinfo
  0.01    0.000001           1         1           prlimit64
  0.00    0.000000           0         3           rt_sigprocmask
  0.00    0.000000           0         4           pread64
  0.00    0.000000           0         1           execve
  0.00    0.000000           0         1           set_tid_address
  0.00    0.000000           0         1           set_robust_list
  0.00    0.000000           0         1           rseq
------ ----------- ----------- --------- --------- ----------------
100.00    0.007646          14       525        17 total
```

## 2. sysdig

### A. Intro

`sysdig` est un outil qui permet de faire pleiiin de trucs, et notamment tracer les *syscalls*  que le kernel reçoit.

Si on le lance sans préciser, il affichera TOUS les *syscalls*  que reçoit votre kernel.

On peut ajouter des filtres, pour ne voir que les *syscalls*  qui nous intéressent.

Par exemple :

```bash
# si on veut tracer les *syscalls*  effectués par le programme echo
sysdig proc.name=echo
```

> Il existe des tonnes et des tonnes de champs utilisables pour les filtres, on peut consulter la liste avec `sysdig -l`.

Ensuite on le laisse tourner, et si un *syscall* est appelé et que ça matche notre filtre, il s'affichera !

Pour installer sysdig, utilisez les commandes suivantes (instructions pour Rocky Linux 9) :

```bash
# mettons complètement à jour l'OS d'abord si nécessaire
sudo dnf update -y 

# installer sysdig et ses dépendances
sudo dnf install -y epel-release
sudo dnf install -y dkms gcc kernel-devel make perl kernel-headers

# redémarrer pour charger la nouvelle version du kernel si besoin (c'est automatique, juste lance un reboot)
sudo reboot

curl -SLO https://github.com/draios/sysdig/releases/download/0.39.0/sysdig-0.39.0-x86_64.rpm
sudo rpm -ivh sysdig-0.39.0-x86_64.rpm
```

### B. Use it

🌞 **Utiliser `sysdig` pour tracer les *syscalls*  effectués par `ls`**

- faites `ls` sur un dossier qui contient des trucs (pas un dossier vide)
- mettez en évidence le *syscall* pour écrire dans le terminal le résultat du `ls`

> Vous pouvez isoler à la main les lignes intéressantes : copier/coller de la commande, et des seule(s) ligne(s) que je vous demande de repérer.

🌞 **Utiliser `sysdig` pour tracer les *syscalls*  effectués par `cat`**

- faites `cat` sur un fichier qui contient des trucs
- mettez en évidence le *syscall* qui demande l'ouverture du fichier en lecture
- mettez en évidence le *syscall* qui écrit le contenu du fichier dans le terminal

🌞 **Utiliser `sysdig` pour tracer les *syscalls*  effectués par votre utilisateur**

- ça va bourriner sec, vu que vous êtes connectés en SSH étou
- juste pour vous éduquer un peu + à ce que fait le kernel à chaque seconde qui passe
- donner la commande pour ça, pas besoin de me mettre le résultat :d

![Too much](./img/doge-strace.jpg)

🌞 **Livrez le fichier `curl.scap` dans le dépôt git de rendu**

- `sysdig` permet d'enregistrer ce qu'il capture dans un fichier pour analyse ultérieure
- l'extension c'est `.scap` par convention
- **capturez les *syscalls*  effectués par un `curl example.org`**

> `sysdig` est un outil moderne qui sert de base à toute la suite d'outils de la boîte du même nom. On pense par exemple à Falco qui permet de tracer, monitorer, lever des alertes sur des *syscalls* , au sein d'un cluster Kubernetes.

## 3. Bonus : Stratoshark

Un tout nouveau tool bien stylé : [Stratoshark](https://wiki.wireshark.org/Stratoshark). L'interface de Wireshark (et ses fonctionnalités de fou) mais pour visualiser des captures de *syscalls*  (et autres).

Vous prenez pas trop la tête avec ça, mais si vous voulez vous amuser avec une interface stylée, il est là !

Vous pouvez exporter une capture `sysdig` avec `sysdig -w meo.scap proc.name=echo` par exemple, et la lire dans Stratoshark. 