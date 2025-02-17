## 2. Proofs

🌞 **Prouvez que le schéma de partitionnement a bien été appliqué**

```PS
[dums@vbox ~]$ lsblk && df -h
NAME             MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                8:0    0   30G  0 disk
├─sda1             8:1    0   20G  0 part
│ ├─rl_vbox-root 253:0    0   10G  0 lvm  /
│ ├─rl_vbox-swap 253:1    0    4M  0 lvm  [SWAP]
│ ├─rl_vbox-var  253:2    0    5G  0 lvm  /var
│ └─rl_vbox-home 253:3    0    5G  0 lvm  /home
└─sda2             8:2    0  512M  0 part /boot
sr0               11:0    1 1024M  0 rom
Filesystem                Size  Used Avail Use% Mounted on
devtmpfs                  4.0M     0  4.0M   0% /dev
tmpfs                     888M     0  888M   0% /dev/shm
tmpfs                     355M  5.0M  350M   2% /run
/dev/mapper/rl_vbox-root  9.8G  1.3G  8.0G  14% /
/dev/sda2                 488M  277M  175M  62% /boot
/dev/mapper/rl_vbox-home  4.9G   44K  4.6G   1% /home
/dev/mapper/rl_vbox-var   4.9G  180M  4.4G   4% /var
tmpfs                     178M     0  178M   0% /run/user/1000
```

🌞 **Mettre en évidence la ligne de configuration `sudo` qui concerne le groupe `wheel`**

```PS
[dums@vbox ~]$ sudo cat /etc/sudoers | grep '%wheel'
[sudo] password for dums:
%wheel  ALL=(ALL)       ALL
# %wheel        ALL=(ALL)       NOPASSWD: ALL
```

🌞 **Prouvez que votre utilisateur est bien dans le groupe `wheel`**
```PS
[dums@vbox ~]$ groups dums | grep wheel
dums : dums wheel
```

🌞 **Prouvez que la langue configurée pour l'OS est bien l'anglais**

```PS
[dums@vbox ~]$ locale | grep LANG
LANG=en_GB.UTF-8
```

🌞 **Prouvez que le firewall est déjà actif**

```PS
[dums@vbox ~]$ sudo systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
     Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; preset: enabled)
     Active: active (running) since Mon 2025-02-17 12:28:21 CET; 22min ago
       Docs: man:firewalld(1)
   Main PID: 683 (firewalld)
      Tasks: 2 (limit: 11101)
     Memory: 44.2M
        CPU: 1.229s
     CGroup: /system.slice/firewalld.service
             └─683 /usr/bin/python3 -s /usr/sbin/firewalld --nofork --nopid

Feb 17 12:28:19 localhost systemd[1]: Starting firewalld - dynamic firewall daemon...
Feb 17 12:28:21 localhost systemd[1]: Started firewalld - dynamic firewall daemon.
```

Suite --> [Partie 2](./part2.md)