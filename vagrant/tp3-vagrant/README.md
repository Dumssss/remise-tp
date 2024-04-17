# TP3 : Self-hosted private cloud platform

## Sommaire

- [TP3 : Self-hosted private cloud platform](#tp3--self-hosted-private-cloud-platform)
  - [Sommaire](#sommaire)
- [0. Prérequis](#0-prérequis)
- [I. Présentation du lab](#i-présentation-du-lab)
  - [1. Architecture](#1-architecture)
  - [2. Noeud Frontend](#2-noeud-frontend)
  - [3. Noeuds KVM](#3-noeuds-kvm)
- [II. Setup](#ii-setup)
  - [1. Frontend](#1-frontend)
  - [2. Noeuds KVM](#2-noeuds-kvm)
  - [3. Réseau](#3-réseau)
- [III. Utiliser la plateforme](#iii-utiliser-la-plateforme)
- [IV. Ajouter d'un noeud et VXLAN](#iv-ajouter-dun-noeud-et-vxlan)
  - [1. Ajout d'un noeud](#1-ajout-dun-noeud)
  - [2. VM sur le deuxième noeud](#2-vm-sur-le-deuxième-noeud)
  - [3. Connectivité entre les VMs](#3-connectivité-entre-les-vms)
  - [4. Inspection du trafic](#4-inspection-du-trafic)

# 0. Prérequis

➜ **Vagrant !**

```bash
# update de tout le système
$ sudo dnf update -y

# ajout du paquets vim
$ sudo dnf install -y vim

# désactivation de SELinux
$ sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
$ sudo setenforce 0
```

➜ Ce TP n'est **qu'une paraphrase gigantesque de [la doc officielle](https://docs.opennebula.io/6.8/)**

➜ **Comprendre un minimum le fonctionnement/l'architecture de OpenNebula** avant de commencer

➜ **Pour les noeuds KVM** il faudra activer la nested virtu

# I. Présentation du lab

## 1. Architecture

| Node           | IP Address  | Rôle                         |
|----------------|-------------|------------------------------|
| `frontend.one` | `10.3.1.11` | WebUI OpenNebula             |
| `kvm1.one`     | `10.3.1.21` | Hyperviseur + Endpoint VXLAN |
| `kvm2.one`     | `10.3.1.22` | Hyperviseur + Endpoint VXLAN |

#### VagrantFile 
```
cluster = {
  "frontend.one" => { :ip => "10.3.1.11" },
  "kvm1.one" => { :ip => "10.3.1.21" }, 
  "kvm2.one" => { :ip => "10.3.1.22" }
}

Vagrant.configure("2") do |config|

  cluster.each_with_index do |(hostname, info), index|

    config.vm.define hostname do |config|
      config.vm.provider "virtualbox" do |vb, override|
        config.vm.box = "cloud.box"
        override.vm.network :private_network, ip: "#{info[:ip]}"
        override.vm.hostname = hostname
        vb.name = hostname
        vb.memory = "2048"
      end
    end
  end
end
```

# II. Utiliser la plateforme

Bah ouais il serait temps nan. Pop des ptites VMs.

OpenNebula fournit des images toutes prêtes, ready-to-use, qu'on peut lancer au sein de notre plateforme Cloud.

➜ **RDV de nouveau sur la WebUI de OpenNebula, et naviguez dans `Settings > Onglet Auth`**

- OpenNebula a généré une paire de clé sur la machine `frontend.one`
- elle se trouve dans le dossier `.ssh` dans le homedir de l'utilisateur `oneadmin`
- déposez la clé publique dans cet interface de la WebUI

> *Dans un cas réel, on poserait clairement une autre clé, la nôtre. On pourrait aussi en déposer plusieurs, s'il y a plusieurs admins dans la boîte. Ca pourrait se faire avec une image custom et du `cloud-init` par exemple. Là on fait ça comme ça, pour pas vous brainfuck avec 14 clés différentes. Appelez-moi pour un setup propre si vous voulez.*

➜ **Toujours sur la WebUI de OpenNebula, naviguez dans `Storage > Apps`**

Récupérez l'image de Rocky Linux 9 dans cette interface.

> Les images proposées par les gars d'OpenNebula, on peut s'y connecter qu'en SSH, il faudra donc pouvoir les joindre niveau IP pour les utiliser.

➜ **Toujouuuuurs sur la WebUI de OpenNebula, naviguez dans `Instances > VMs`**

- créez votre première VM :
  - doit utiliser l'image Rocky Linux 9 qu'on a créé précédemment
  - doit utiliser le virtual network créé précédemment

➜ **Tester la connectivité à la VM**

- déjà est-ce qu'on peut la ping ?
  - depuis le noeud `kvm1.one`, faites un `ping` vers l'IP de la VM
  - l'IP de la VM est visible dans la WebUI
- pour pouvoir se co en SSH, il faut utiliser la clé de `oneadmin`, suivez le guide :

```bash
# connectez vous en SSH sur la machine frontend.one
❯ vagrant ssh frontend

# devenez l'utilisateur oneadmin
[vagrant@frontend ~]$ sudo su - oneadmin

# lancez un agent SSH (demandez-moi si vous voulez une explication sur ça)
[oneadmin@frontend ~]$ eval $(ssh-agent)

# ajoutez la clé privée à l'agent SSH
[oneadmin@frontend ~]$ ssh-add
Identity added: /var/lib/one/.ssh/id_rsa (oneadmin@frontend)

# se connecter à kvm1 en faisant suivre l'agent SSH
[oneadmin@frontend ~]$ ssh -A 10.231.231.21

# depuis kvm1, se connecter à la VM, sur l'utilisateur root
[oneadmin@kvm1 ~]$ ssh root@10.220.220.1

# on est co dans la VM
[root@localhost ~]# 
```

➜ **Si vous avez bien un shell dans la VM, vous êtes au bout des péripéties, pour un setup basique !**

- vous pouvez éventuellement ajouter l'IP de la machine hôte comme route par défaut pour avoir internet (l'IP du bridge VXLAN de l'hôte) :

```bash
[root@localhost ~]# ip route add default via 10.220.220.201
[root@localhost ~]# ping 1.1.1.1
```

> *Il est possible de réaliser cette suite de commande en une seule commande grâce aux **jumps SSH**. Demandez-moi pour que je vous montre (ou renseignez-vous sur Google). Mais genre il est possible de juste taper, depuis votre PC, `ssh vm` et ça fait les trois connexions d'affilée :)*

# IV. Ajouter d'un noeud et VXLAN

## 1. Ajout d'un noeud

🌞 **Setup de `kvm2.one`, à l'identique de `kvm1.one`** excepté :

- une autre IP statique bien sûr
- idem, pour le bridge, donnez-lui l'IP `10.220.220.202/24` (celle qui est juste après l'IP du bridge de `kvm1`)
- une fois setup, ajoutez le dans la WebUI, dans `Infrastructure > Hosts`

## 2. VM sur le deuxième noeud

🌞 **Lancer une deuxième VM**

- vous pouvez la forcer à tourner sur `kvm2.one` lors de sa création
- mettez la dans le même réseau que le premier `kvm1.one`
- assurez-vous que vous pouvez vous y connecter en SSH

## 3. Connectivité entre les VMs

🌞 **Les deux VMs doivent pouvoir se ping**

- alors qu'elles sont sur des hyperviseurs différents, elles se ping comme si elles étaient dans le même réseau local !

## 4. Inspection du trafic

🌞 **Téléchargez `tcpdump` sur l'un des noeuds KVM**

- effectuez deux captures, pendant que les VMs sont en train de se ping :
  - **une qui capture le trafic de l'interface réelle** : `eth1` probablement (celle qui a l'IP host-only, celle qui porte `10.3.1.22` sur `kvm2` par exemple)
  - **une autre qui capture le trafic de l'interface bridge VXLAN**
    - on l'a appelée `vxlan-bridge` dans le TP
- petit rappel d'une commande `tcpdump` :

```bash
# capturer le trafic de eth1, et l'enregistrer dans un fichier yo.pcap
tcpdump -i eth1 -w yo.pcap
```

➜ **Analysez les deux captures**

- dans la capture de `eth1` vous devriez juste voir du trafic UDP entre les deux noeuds
  - si vous regardez bien, vous devriez que ce trafic UDP contient lui-même des trames
- dans la capture de `vxlan-bridge`, vous devriez voir les "vraies" trames échangées par les deux VMs

![VXLAN](./img/vxlan.jpg)
