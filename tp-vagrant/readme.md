# TP1 : Programmatic provisioning

## Sommaire

- [TP1 : Programmatic provisioning](#tp1--programmatic-provisioning)
  - [Sommaire](#sommaire)
- [I. Une première VM](#i-une-première-vm)
  - [1. ez startup](#1-ez-startup)
  - [2. Un peu de conf](#2-un-peu-de-conf)
- [II. Initialization script](#ii-initialization-script)
- [III. Repackaging](#iii-repackaging)
- [IV. Multi VM](#iv-multi-vm)
- [V. cloud-init](#v-cloud-init)


# I. Une première VM
Pour le moment, la conf, on s'en branle, on va juste allumer la VM ! Komsa :

```bash
$ vagrant up
$ vagrant status
$ vagrant ssh
$ vagrant ssh-config
$ vagrant halt
$ vagrant destroy -f
```

🌞 **`1er Vagrantfile` [VagrantFile1](./Vagrantfile1)**



## 2. Un peu de conf

Avec Vagrant, il est possible de gérer un certains nombres de paramètres de la VM.

```bash
$ vagrant plugin install vagrant-disksize
```

🌞 **2ème VagrantFile** : [VagrantFile2](./Vagrantfile2)

# II. Initialization script

Quand Vagrant allume une VM, il peut lui ordonner d'exécuter un script une fois le démarrage terminé.

> On se rapproche donc d'un réel provisioning programmatique avec la création de la VM + une configuration élémentaire.

Ici, on va rester simples : un ptit script shell qui installera quelques paquets.

🌞 **Ajustez le `Vagrantfile`** :

- quand la VM démarre, elle doit exécuter un script bash
- le script installe les paquets `vim` et `python3`
- il met aussi à jour le système avec un `dnf update -y` (si c'est trop long avec le réseau de l'école, zappez cette étape)
- ça se fait avec une ligne comme celle-ci :

```Vagrantfile
# on suppose que "script.sh" existe juste à côté du Vagrantfile
config.vm.provision "shell", path: "script.sh" 
```

🌞 **3ème VagrantFile** : [VagrantFile3](./Vagrantfile3)

🌞 **Script Python** : [script.sh](./script.sh)

# III. Repackaging
```bash
$ vagrant package --output rocky-efrei.box
$ vagrant box add rocky-efrei rocky-efrei.box
$ vagrant box list
```

# IV. Multi VM

Il est -évidemment- possible de créer plusieurs VMs à l'aide d'un seul `Vagrantfile` et donc de une seule commande `vagrant up`.

Il y a deux façons de faire ça dans le `Vagrantfile` :

🌞 **Duplication de Code** : [VagrantFile4](./VagrantFile4-duplication)

🌞 **Avec un Tableau** : [VagrantFile4](./Vagrantfile4-avecTableau)

**Une fois les VMs allumées, assurez-vous que vous pouvez ping `10.1.1.102` depuis `node1`**

Ping de Node 1 vers Node 2 : 

```bash
[vagrant@node1 ~]$ ping 10.1.1.102
PING 10.1.1.102 (10.1.1.102) 56(84) bytes of data.
64 bytes from 10.1.1.102: icmp_seq=1 ttl=64 time=2.03 ms
64 bytes from 10.1.1.102: icmp_seq=2 ttl=64 time=0.970 ms

64 bytes from 10.1.1.102: icmp_seq=3 ttl=64 time=1.97 ms

^C
--- 10.1.1.102 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2009ms
rtt min/avg/max/mdev = 0.970/1.654/2.026/0.484 ms
```

Ping de Node 2 vers Node 1 : 

```bash
$ vagrant ssh node2.tp1.efrei
[vagrant@node2 ~]$ ping 10.1.1.101
PING 10.1.1.101 (10.1.1.101) 56(84) bytes of data.
64 bytes from 10.1.1.101: icmp_seq=1 ttl=64 time=5.53 ms

^C
--- 10.1.1.101 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 5.528/5.528/5.528/0.000 ms
```

# V. cloud-init

Vous vous souvenez de lui ? Non ? Bah tant mieux, petite partie pour vous rafraîchir la mémoire justement :D

**`cloud-init` est un outil qui permet à une VM de s'autoconfigurer dès le premier boot.**

Ca permet d'avoir une syntaxe standard pour définir des trucs standards (créer un user, poser une clé SSH, installer un paquet, etc), plutôt que de reposer sur des scripts shell super spécifiques, et prompts à l'erreur.

De plus, énormément d'OS l'ont adopté, c'est devenu un techno de choix chez la plupart des hébergeurs cloud dans les chaînes de provisioning des opérateurs Cloud.

> *Toutes les plateformes cloud comme Azure ou AWS ou d'autres utilisent `cloud-init` pour créer des VMs avec un user et une clé SSH déposés pour vous.*

---

Ici, dans le cadre du TP, vous allez :

- ajouter `cloud-init` à la box que vous avez repackagée
- créer un fichier `.iso` qui contient les données `cloud-init` de notre choix
  - comme une création d'utilisateurs
- on pourra ensuite lancer une VM, qui se base sur cette box, et qui s'autoconfigurera toute seule au boot

🌞 **Repackager une box Vagrant**

- cette box doit contenir le paquet `cloud-init` pré-installé
- il faut aussi avoir saisi `systemctl enable cloud-init` après avoir l'instalaltion du paquet
  - cela permet à `cloud-init` de démarrer automatiquement au prochain boot de la machine

🌞 **Tester !**

- écrire un `Vagrantfile` qui utilise la box repackagée
- il faudra ajouter un CD-ROM (un `.iso`) à la VM qui contient nos données `cloud-init`
  - uiui un `.iso` c'est un CD-ROM virtuel, et ui c'est la méthode plutôt standard avec `cloud-init`
  - référez-vous aux instructions juste en dessous pour savoir comment construire ce `.iso`
- allumez la VM avec `vagrant up` et vérifiez que `cloud-init` a bien créé l'utilisateur, avec le bon password, et la bonne clé SSH

➜ **Construire le `.iso` qui contient les données `cloud-init`**

- première étape, créer un fichier texte nommé `user-data` avec le contenu suivant

```yml
---
local-hostname: cloud-init-test.tp1.efrei
```

- ensuite, créer un fichier texte nommé `user-data` avec le contenu suivant

```yml
---
users:
  - name: nom_de_ton_user
    primary_group: nom_de_ton_groupe # pareil que le user généralement
    groups: wheel # sur un système redhat, t'as full accès à sudo si t'es membre du groupe wheel
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL # on fait les forceurs sur sudo :D
    lock_passwd: false
    passwd: <HASH_DU_PASSWORD_MEME_FORMAT_QUE_/etc/shadow>
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1l3R4CNTE5AAAAIMO/JQ3AtA3k8iXJWlkdUKSHDh215OKyLR0vauzD7BgA # mettez votre propre clé
```

- enfin, on peut générer le `.iso` à partir de ces deux fichiers avec la commande suivante

```bash
# rien à changer dans cette commande, à part le nom de l'iso de sortie si vous souhaitez
# il faut OBLIGATOIREMENT laisser le volid à "cidata" : c'est grâce à ce tag que cloud-init reconnaît ce disque
genisoimage -output cloud-init.iso -volid cidata -joliet -r meta-data user-data
```

![No magic](./img/cloud-init.png)