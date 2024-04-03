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
3 packets t me 2009ms
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

## 1. Repackaging
D'abord, j'ai installé cloud-init en utilisant un script : 
```shell
#!/bin/bash
dnf update -y
dnf install -y cloud-init
systemctl enable cloud-init
```
```bash
$ vagrant up
$ vagrant halt
$ vagrant destroy -f
```
Repackaging de la VM à jour, avec cloud-init installé et activé

```bash
$ vagrant package --output rocky-efrei.box
$ vagrant box add rocky-efrei rocky-efrei.box
```
Voila le contenue du fichier user-data.yml

```yml
---
users:
  - name: dums
    primary_group: dums
    groups: wheel
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: $6$EbQdmgPn.R5sovC1$zImZCb3F9zaGH95/Jay36oHo1iPnlxIy31Iis8gGdHWv3RHW3K3ueyElogId6IIFaFn5exI5vXadclkyKLbPo.
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDk5mazPHyLDnYEzZdR+vo5AN6iICwd8RYhXlVz0sdUfU3Oqr19ovKPyp1DGJZENwSWPieFqARJd24c+yieQBgLvxwp5VV7MtscygqOTZ9n5vfHa78b04sjFjlzIeZJxTKc9nrP8nGGi6J6WxuqEWPycZE1hg5UBpx0ppbdt3YYNimcxVy47FZiHEOk1kNZkhjH0jfCGuov5JU6ZRtfcbqx77KoIaGzBdn1hiGxY/uxrOB0kTVLtFAppWJOtvbmAQ4EivK5uuDr4KAz7bR8+UwCcRUdo3Y8Eue5M4cRIer3Bk4IcjAHdNDBcpcPLd4VDg2kD+gqO8E7M3k3oE+N6jl cleme@DESKTOP-E1R0286


```
Voila la ligne de commande que j'ai insérée dans le VagrantFile :

```bash
config.vm.cloud_init :user_data, content_type: "text/cloud-config", path: "user_data.yml"
```
Voila le  **VagrantFile final** : [VagrantFile5](./Vagrantfile5)

Vérification de l'utilisateur : 
```bash 
[vagrant@rocky-cloud-init ~]$ cat /etc/passwd
dums:x:1001:1001::/home/dums:/bin/bash
```