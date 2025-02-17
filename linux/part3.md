# Part III : Storage is still disks in 2025
## 1. LVM

*LVM* (pour *Logical Volume Manager*) est l'outil de référence aujourd'hui sous Linux pour créer et gérer les partitions des disques.

> Il a beaucoup beaucoup trop de features de fou, il se contente pas de couper des disques !

🌞 **Afficher l'état actuel de LVM**

- afficher la liste des *PV* (*Physicals Volumes*)
```PS
[dums@vbox ~]$ sudo pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda1
  VG Name               rl_vbox
  PV Size               20.01 GiB / not usable 4.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              5122
  Free PE               1
  Allocated PE          5121
  PV UUID               jF7yiI-fl2H-Y8dI-Ot63-35kx-Pmrz-rk9Mrv
```
- afficher la liste des *VG* (*Volume Groups*)
```ps
[dums@vbox ~]$ sudo vgdisplay
  --- Volume group ---
  VG Name               rl_vbox
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  5
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                4
  Open LV               4
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <20.01 GiB
  PE Size               4.00 MiB
  Total PE              5122
  Alloc PE / Size       5121 / 20.00 GiB
  Free  PE / Size       1 / 4.00 MiB
  VG UUID               1rm3ry-B3c8-WxD8-DgxB-cc1c-TtAj-GZntAg
```
- afficher la liste des *LV* (*Logical Volumes*)
```ps
[dums@vbox ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/rl_vbox/var
  LV Name                var
  VG Name                rl_vbox
  LV UUID                NG5vWm-LkNR-anFt-BW7B-7SFY-5Mkz-1RemhA
  LV Write Access        read/write
  LV Creation host, time vbox, 2025-02-17 12:01:44 +0100
  LV Status              available
  # open                 1
  LV Size                5.00 GiB
  Current LE             1280
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2

  --- Logical volume ---
  LV Path                /dev/rl_vbox/root
  LV Name                root
  VG Name                rl_vbox
  LV UUID                R5Tilv-hVNY-2J0o-y2dq-1nhZ-5emR-AfPl0q
  LV Write Access        read/write
  LV Creation host, time vbox, 2025-02-17 12:01:45 +0100
  LV Status              available
  # open                 1
  LV Size                10.00 GiB
  Current LE             2560
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

  --- Logical volume ---
  LV Path                /dev/rl_vbox/home
  LV Name                home
  VG Name                rl_vbox
  LV UUID                EW9MDX-0bd9-LtxF-fHH3-dGrI-Q70G-beuydI
  LV Write Access        read/write
  LV Creation host, time vbox, 2025-02-17 12:01:45 +0100
  LV Status              available
  # open                 1
  LV Size                5.00 GiB
  Current LE             1280
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:3

  --- Logical volume ---
  LV Path                /dev/rl_vbox/swap
  LV Name                swap
  VG Name                rl_vbox
  LV UUID                zUTE2s-EXSY-ME12-C8or-1xWo-Fdhd-lYxqVd
  LV Write Access        read/write
  LV Creation host, time vbox, 2025-02-17 12:01:45 +0100
  LV Status              available
  # open                 2
  LV Size                4.00 MiB
  Current LE             1
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:1
```

🌞 **Déterminer le type de système de fichiers**

- de la partition montée sur `/`
```ps
[dums@vbox ~]$ fsck -N /dev/sda1/─rl_vbox-root
fsck from util-linux 2.37.4
[/usr/sbin/fsck.ext2 (1) -- /dev/sda1/─rl_vbox-root] fsck.ext2 /dev/sda1/─rl_vbox-root
```
- de la partition montée sur `/home`
```ps
[dums@vbox ~]$ fsck -N /dev/sda1/─rl_vbox-home
fsck from util-linux 2.37.4
[/usr/sbin/fsck.ext2 (1) -- /dev/sda1/─rl_vbox-home] fsck.ext2 /dev/sda1/─rl_vbox-home
```
## 2. HELP my partition is full


🌞 **Remplissez votre partition `/home`**

- on va simuler avec un truc bourrin :

```
dd if=/dev/zero of=/home/dums/bigfile bs=4M count=2500
```
🌞 **Constater que la partition est pleine**

```ps
[dums@vbox ~]$ df -h /dev/mapper/rl_vbox-home
Filesystem                Size  Used Avail Use% Mounted on
/dev/mapper/rl_vbox-home  4.9G  4.6G     0 100% /home
```

🌞 **Agrandir la partition**

- D'abord je créer la participation manquante : 
```ps
[dums@vbox ~]$ sudo pvcreate /dev/sda3
  Physical volume "/dev/sda3" successfully created.
```

- avec des commandes LVM il faut agrandir le logical volume
```ps
[dums@vbox ~]$ sudo lvextend -L+8G /dev/mapper/rl_vbox-home
  Size of logical volume rl_vbox/home changed from 5.00 GiB (1281 extents) to 13.00 GiB (3329 extents).
  Logical volume rl_vbox/home successfully resized.
```
- ensuite il faudra indiquer au système de fichier ext4 que la partition a été agrandie
```ps
[dums@vbox ~]$ sudo resize2fs /dev/mapper/rl_vbox-home
resize2fs 1.46.5 (30-Dec-2021)
Filesystem at /dev/mapper/rl_vbox-home is mounted on /home; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
The filesystem on /dev/mapper/rl_vbox-home is now 3408896 (4k) blocks long.
```

- prouvez avec un `df -h` que vous avez récupéré de l'espace en plus

```ps 
[dums@vbox ~]$ df -h /dev/mapper/rl_vbox-home
Filesystem                Size  Used Avail Use% Mounted on
/dev/mapper/rl_vbox-home   13G  4.6G  7.6G  38% /home
```

🌞 **Remplissez votre partition `/home`**

- on va simuler encore avec un truc bourrin :

```
dd if=/dev/zero of=/home/dums/bigfile bs=4M count=2500
```
➜ **Eteignez la VM et ajoutez lui un disque de 40G**

🌞 **Utiliser ce nouveau disque pour étendre la partition `/home` de 20G**

- dans l'ordre il faut :
- indiquer à LVM qu'il y a un nouveau PV dispo
- ajouter ce nouveau PV au VG existant
- étendre le LV existant pour récupérer le nouvel espace dispo au sein du VG
- indiquer au système de fichier ext4 que la partition a été agrandie
- prouvez avec un `df -h` que vous avez récupéré de l'espace en plus

## 3. Prepare another partition

Pour la suite du TP, on va préparer une dernière partition. Il devrait vous rester 20G de libre avec le disque de 40 que vous venez d'ajouter.

**Cette partition contiendra des fichiers HTML pour des sites web (fictifs).**

🌞 **Créez une nouvelle partition**

- le LV doit s'appeler `web`
- elle doit faire 20G et être formatée en ext4
- il faut la monter sur `/var/www`

🌞 **Proposez au moins une option de montage**

- au moment où on monte la partition (avec fstab ou la commande `mount`), on peut choisir des options de montage
- proposez au moins une option de montage qui augmente le niveau de sécurité lors de l'utilisation de la partition
- je rappelle que la partition ne contiendra que des fichiers HTML
