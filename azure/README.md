# TP1 : Azure first steps

# I. Prérequis

## 1. Starting blocks

➜  **Activez notre compte Azure for Students**

➜ **Installer Terraform sur notre poste**

## 2. Une paire de clés SSH

### A. Choix de l'algorithme de chiffrement

🌞 **Déterminer quel algorithme de chiffrement utiliser pour vos clés**

- Faiblesse dans le chiffrement RSA : [RSA](https://www.bibmath.net/crypto/index.php?action=affiche&quoi=chasseur/erreurrsa)
- Voila une source fiable pour trouver un autre algo que RSA : [ECC](https://www.sectigo.com/resource-library/rsa-vs-dsa-vs-ecc-encryption#:~:text=An%20ECC%20key%20is%20more,key%20of%20the%20same%20size)
- Chiffrement choisi : **ECDSA**


### B. Génération de votre paire de clés

🌞 **Générer une paire de clés pour ce TP**

```PS 
> ssh-keygen -t ecdsa
Generating public/private ecdsa key pair.
Enter file in which to save the key (C:\Users\cleme/.ssh/id_ecdsa): C:\Users\cleme/.ssh/cloud_tp1
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in C:\Users\cleme/.ssh/cloud_tp1
Your public key has been saved in C:\Users\cleme/.ssh/cloud_tp1.pub
The key fingerprint is:
SHA256:K1s0WaWkRnFRE6UUSZ/ikDm3dPdAwkT5vhMiP7wWmks cleme@laptop-clement
The key's randomart image is:
+---[ECDSA 256]---+
|        o.+B%*o  |
|       . + *+* . |
|        o B =.= .|
|       . o * +.o.|
|        S   o.  .|
|       . o. o o  |
|      . o E* o o |
|       + .o = o  |
|      .   .o.o . |
+----[SHA256]-----+
```

### C. Agent SSH

🌞 **Configurer un agent SSH sur votre poste**

```PS
PS C:\WINDOWS\system32> Set-Service -Name ssh-agent -StartupType Manual
PS C:\WINDOWS\system32> Start-Service ssh-agent
PS C:\WINDOWS\system32> ssh-add $env:USERPROFILE\.ssh\cloud_tp1
Enter passphrase for C:\Users\cleme\.ssh\cloud_tp1:
Identity added: C:\Users\cleme\.ssh\cloud_tp1 (cleme@laptop-clement)
PS C:\WINDOWS\system32> ssh-add -l
256 SHA256:K1s0WaWkRnFRE6UUSZ/ikDm3dPdAwkT5vhMiP7wWmks cleme@laptop-clement (ECDSA)
```

# II. Spawn des VMs

## 1. Depuis la WebUI

➜ **Faites du cliclic partout dans la WebUI Azure pour créer une VM dans Azure.**


```ssh clement@<IP_PUBLIQUE>```

## 2. `az` : a programmatic approach

🌞 **Créez une VM depuis le Azure CLI**

```bash
az login
az group create --location uksouth --name <dums-group>
az vm create --resource-group <dums-group> --name <vm1> --image Ubuntu2204 --admin-username <dums> --ssh-key-values <C:\Users\cleme/.ssh/cloud_tp1.pub>
```

🌞 **Assurez-vous que vous pouvez vous connecter à la VM en SSH sur son IP publique**

```bash
az vm show -d -g <dums-group> -n <vm1> --query publicIps -o tsv
ssh dums@IP_PUBLIQUE
```


🌞 **Une fois connecté, prouvez la présence...**

- **...du service `walinuxagent.service`**

```bash
systemctl status walinuxagent.service
walinuxagent.service - Azure Linux Agent
     Loaded: loaded (/lib/systemd/system/walinuxagent.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2025-09-16 10:02:32 CEST; 5min ago
```

- **...du service `cloud-init.service`**
```bash
systemctl status cloud-init.service
cloud-init.service - Cloud-init target
     Loaded: loaded (/lib/systemd/system/cloud-init.service; enabled; vendor preset: enabled)
     Active: active (exited) since Tue 2025-09-16 10:02:30 CEST; 5min ago
```

## 3. Terraforming ~~planets~~ infrastructures

**Une dernière section pour jouer avec Terraform,** on se contente là encore de simplement créer une VM Azure.

🌞 **Utilisez Terraform pour créer une VM dans Azure**
```bash
terraform init
terraform validate
terraform plan
terraform apply
```

🌞 **Prouvez avec une connexion SSH sur l'IP publique que la VM est up**

- toujours pas de password avec votre Agent SSH normalement 🐈
```bash
ssh dums@IP_PUBLIQUE
Welcome to Ubuntu 22.04.5 LTS ...
```
---