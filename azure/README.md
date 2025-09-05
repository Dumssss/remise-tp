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


🌞 **Connectez-vous en SSH à la VM pour preuve**

- cette connexion ne doit demander aucun password : votre clé a été ajoutée à votre Agent SSH

## 2. `az` : a programmatic approach

🌞 **Créez une VM depuis le Azure CLI**

- en utilisant uniquement la commande `az` donc
- je vous laisse faire vos recherches pour créer une VM avec la commande `az`
- vous devrez préciser :

    - quel utilisateur doit être créé à la création de la VM
    - le fichier de clé utilisé pour se connecter à cet utilisateur
    - comme ça, dès que la VM pop, on peut se co en SSH !

???+ note

    **Par exemple**, une commande simple pour faire ça, elle suppose qu'une clé publique SSH existe dans `~/.ssh/id_ed25519.pub`  
    ```bash
    az group create --location uksouth --name meo
    az vm create -g meo -n super_vm --image Ubuntu2204 --admin-username <ton nom de user ici> --ssh-key-values ~/.ssh/id_ed25519.pub
    ```

???+ tip

    Je vous recommande d'utiliser le très stylé `az interactive` qui autocomplète vos commandes `az`.  
    Il intègre même une doc ambulante des options et arguments, vraiment cool :)

🌞 **Assurez-vous que vous pouvez vous connecter à la VM en SSH sur son IP publique**

- une commande SSH fonctionnelle vers la VM sans password toujouuurs because Agent SSH

???+ warning

    Pratique de pouvoir se connecter en utilisant une IP publique comme ça !  
    En revanche votre offre *Azure for Students* ne vous donne le droit d'utiliser que 3 IPs publiques.  
    **Pensez donc bien à supprimer les ressources au fur et à mesure du TP si besoin.**

🌞 **Une fois connecté, prouvez la présence...**

- **...du service `walinuxagent.service`**

???+ note

    Ce service est spécifique à Azure. Il permet à Azure d'interagir avec la VM.

- **...du service `cloud-init.service`**

???+ note

    `cloud-init` est un outil **très standard et répandu dans tous les environnements Cloud**.  
    Il permet d'effectuer de la configuration automatiquement **au premier lancement de la VM**.  
    C'est **lui qui a créé votre utilisateur et déposé votre clé pour se co en SSH !**  
    Vous pouvez vérifier qu'il s'est bien déroulé avec la commande `cloud-init status`

## 3. Terraforming ~~planets~~ infrastructures

**Une dernière section pour jouer avec Terraform,** on se contente là encore de simplement créer une VM Azure.

???+ tip

    Je vous donne en [section 4 juste en dessous](#4-exemple-dutilisation-azure-terraform) un exemple de setup pour les fichiers Terraform, setup que je vous recommande d'utiliser pour créer une VM dans Azure avec Terraform.  
    Un simple déploiement de une VM prend déjà pas mal de lignes : on déclare **toutes les ressources Azure explicitement**.

🌞 **Utilisez Terraform pour créer une VM dans Azure**

- j'veux la suite de commande `terraform` utilisée dans le compte-rendu

???+ note

    Vous pouvez couper un peu l'ouput de votre `terraform apply` pour le compte-rendu, il est immense :d

📁 **Fichiers à rendre**

- `main.tf`
- tout autre fichier utilisé par Terraform (je vous propose des fichiers de base plus bas)

🌞 **Prouvez avec une connexion SSH sur l'IP publique que la VM est up**

- toujours pas de password avec votre Agent SSH normalement 🐈

---

## 4. Exemple d'utilisation Azure + Terraform

Parce que jui pas ~~trop~~ un animal, j'vous file un bon pattern de fichiers Terraform qui fait le job.

**Créez un dossier dédié** et déposez ces 3 fichiers :

### A. Création de fichiers

#### ➜ `main.tf`

`main.tf` : fait le job, il crée une par une toutes les ressources Azure nécessaires pour une VM fonctionnelle

??? example

    ```tf
    # main.tf

    provider "azurerm" {
      features {}
      subscription_id = var.subscription_id
    }
    
    resource "azurerm_resource_group" "main" {
      name     = var.resource_group_name
      location = var.location
    }
    
    resource "azurerm_virtual_network" "main" {
      name                = "vm-vnet"
      address_space       = ["10.0.0.0/16"]
      location            = azurerm_resource_group.main.location
      resource_group_name = azurerm_resource_group.main.name
    }
    
    resource "azurerm_subnet" "main" {
      name                 = "vm-subnet"
      resource_group_name  = azurerm_resource_group.main.name
      virtual_network_name = azurerm_virtual_network.main.name
      address_prefixes     = ["10.0.1.0/24"]
    }
    
    resource "azurerm_network_interface" "main" {
      name                = "vm-nic"
      location            = azurerm_resource_group.main.location
      resource_group_name = azurerm_resource_group.main.name
    
      ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.main.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.main.id
      }
    }
    
    resource "azurerm_public_ip" "main" {
      name                = "vm-ip"
      location            = azurerm_resource_group.main.location
      resource_group_name = azurerm_resource_group.main.name
      allocation_method   = "Dynamic"
      sku                 = "Basic"
    }
    
    resource "azurerm_linux_virtual_machine" "main" {
      name                = "super-vm"
      resource_group_name = azurerm_resource_group.main.name
      location            = azurerm_resource_group.main.location
      size                = "Standard_B1s"
      admin_username      = var.admin_username
      network_interface_ids = [
        azurerm_network_interface.main.id,
      ]
    
      admin_ssh_key {
        username   = var.admin_username
        public_key = file(var.public_key_path)
      }
    
      os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
        name                 = "vm-os-disk"
      }
    
      source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-focal"
        sku       = "20_04-lts"
        version   = "latest"
      }
    }
    ```

???+ note 

    On est vraiment au strict minimum là, prenez le temps de regarder un peu chaque ressource, capter à quoi elle sert. En particulier le Resource Group.

#### ➜ `variables.tf`

`variables.tf` : déclare les variables que peuvent utiliser les fichiers `.tf` (**déclaration** de variables)

??? example

    ```tf
    # variables.tf
    
    variable "resource_group_name" {
      type        = string
      description = "Name of the resource group"
    }
    
    variable "location" {
      type        = string
      default     = "East US"
      description = "Azure region"
    }
    
    variable "admin_username" {
      type        = string
      description = "Admin username for the VM"
    }
    
    variable "public_key_path" {
      type        = string
      description = "Path to your SSH public key"
    }
    
    variable "subscription_id" {
      type        = string
      description = "Azure subscription ID"
    }
    ```

#### ➜ `terraform.tfvars`

`terraform.tfvars` : définissez des valeurs pour les variables ici (**affectation** de variables)

???+ info

    **Vous allez avoir besoin de votre Subscription ID** : l'identifiant unique de votre abonnement Azure for Students.  
    Vous pouvez le récupérer depuis la WebUI ou avec une commande `az account show --query id`.

??? example

    Fichier `terraform.tfvars`
    ```tf
    resource_group_name = "choisis un nom de resource group :)"
    admin_username = "met ton username là"
    public_key_path = "chemin vers ta clé publique ici"
    location = "uksouth"
    subscription_id = "met ton Subscription ID azure là"
    ```

???+ danger 

    **HA** et évitez de `git push` votre Subscription ID sur une plateforme publique.  
    Bon y'a pas trop trop de conséquences, et c'est le compte Azure de l'EFREI, mais sait-on jamais.  
    De plus, on prend juste pas une mauvaise habitude à push des secrets publiquement là 👿

### B. Commandes Terraform

**Une fois les 3 fichiers en place** (`main.tf`, `variables.tf`, `terraform.tfvars`), déplacez-vous dans le dossier, et utilisez des commandes `terraform` :

```bash
# On se déplace dans le dossier qui contient le main.tf et les autres fichiers
cd terraform/

# Initialisation de Terraform, utile une seule fois
# Ici, Terraform va récupérer le nécessaire pour déployer sur Azure spécifiquement
terraform init

# Si vous voulez voir ce qui serait fait avant de déployer, vous pouvez :
terraform plan

# Pour déployer votre "plan Terraform" (ce qui est défini dans le main.tf)
terraform apply

# Pour détruire tout ce qui a été déployé (recommandé de le faire régulièrement pour déployer depuis zéro)
terraform destroy
```

![Shutdown VMs](../../assets/img/meme_shutdown_vms.png)