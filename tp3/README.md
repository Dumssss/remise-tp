# Mise en place de la topologie et routage

- [Mise en place de la topologie et routage](#mise-en-place-de-la-topologie-et-routage)
  - [Présentation](#présentation)
    - [Topologie](#topologie)
    - [Tableau d'adressage](#tableau-dadressage)
  - [I. Setup GNS3](#i-setup-gns3)
  - [II. Routes routes routes](#ii-routes-routes-routes)
  - [Potit bilan](#potit-bilan)

## Présentation

![Dat topo](../img/dat_topo.jpg)

Cette partie se concentre sur les niveaux 2 et 3 du réseau : les MAC et les IP. On parle pas de serveurs ou quoique ce soit, juste faire en sorte que tout le monde se `ping`, à travers des réseaux différents.

> Lisez bien les étapes dans l'ordre. Je vous donne, dans un ordre cohérent, les étapes de configuration à réaliser.

### Topologie

![Topologie 1](./../img/topo1.png)

### Tableau d'adressage

| Machine          | Réseau 1        | Réseau 2        | Réseau 3        |
| ---------------- | --------------- | --------------- | --------------- |
| `node1.net1.tp3` | `10.3.1.11/24`  | nop             | nop             |
| `node2.net1.tp3` | `10.3.1.12/24`  | nop             | nop             |
| `router1.tp3`    | `10.3.1.254/24` | nop             | `10.3.100.1/30` |
| `router2.tp3`    | nop             | `10.3.2.254/24` | `10.3.100.2/30` |
| `node1.net2.tp3` | nop             | `10.3.2.11/24`  | nop             |
| `node2.net2.tp3` | nop             | `10.3.2.12/24`  | nop             |

## I. Setup GNS3

🌞 **Mettre en place la topologie dans GS3**

- reproduisez la topologie, configurez les IPs et les noms sur toutes les machines
- une fois en place, assurez-vous donc que :
  - toutes les machines du réseau 1 peuvent se `ping` entre elles
  - toutes les machines du réseau 2 peuvent se `ping` entre elles
  - toutes les machines du réseau 3 peuvent se `ping` entre elles
- le `router1.tp3` doit avoir un accès internet normal
  - référez-vous au TP2 pour le setup
  - prouvez avec une commande `ping` qu'il peut joindre une IP publique connue
  - prouvez avec une commande `ping` qu'il peut joindre des machines avec leur nom DNS public (genre `efrei.fr`)

> Pour rappel, l'expression "avoir internet" sur une machine donnée désigne plusieurs choses techniquement parlant : être connecté à un routeur physiquement, que ce routeur soit défini comme la passerelle de la route par défaut sur la machine en question, et cette machine doit aussi connaître l'adresse IP d'un serveur DNS qui est joignable depuis son réseau.

## II. Routes routes routes

🌞 **Activer le routage sur les deux machines `router`**

```bash
# On active le forwarding IPv4
[it4@router ~]$ sudo sysctl -w net.ipv4.ip_forward=1 
net.ipv4.ip_forward = 1

# Petite modif du firewall qui nous bloquerait sinon
[it4@router ~]$ sudo firewall-cmd --add-masquerade
success

# Et on tape aussi la même commande une deuxième fois, en ajoutant --permanent pour que ce soit persistent après un éventuel reboot
[it4@router ~]$ sudo firewall-cmd --add-masquerade --permanent
success
```

🌞 **Mettre en place les routes locales**

- ajoutez les routes nécessaires pour que les membres du réseau 1 puissent joindre les membres du réseau 2 (et inversement)
- **attention** : n'ajoutez que les routes strictement nécessaires
- chaque machine ne doit connaître une route que vers les réseaux dont il a besoin

> *Attention, aucune route par défaut ne doit être configurée pour le moment. Uniquement des routes statiques vers des réseaux précis.*

➜ Par exemple, `node1.net1.tp3` :

- sait déjà joindre le réseau 1, car il est lui même dedans
- a besoin d'une route vers le réseau 2, qui utilise `router1.tp3` comme passerelle
- il n'a pas besoin de connaître une route vers le réseau 3
- référez-vous au [**mémo**](../../../memo/rocky_network.md) pour ça !

> ***N'ajoutez aucune route vers le réseau 3.***

🌞 **Mettre en place les routes par défaut**

- faire en sorte que toutes les machines de votre topologie aient un accès internet, il faut donc :
  - sur les machines du réseau 1, ajouter `router.net1.tp3` comme passerelle par défaut
  - sur les machines du réseau 2, ajouter `router.net2.tp3` comme passerelle par défaut
  - sur l`router.net2.tp3`, ajouter `router1.net.tp3` comme passerelle par défaut
- prouvez avec un `ping` depuis `node1.net1.tp3` que vous avez bien un accès internet
- prouvez avec un `traceroute` depuis `node2.net1.tp3` que vous avez bien un accès internet, et que vos paquets transitent bien par `router2.tp3` puis par `router1.tp3` avant de sortir vers internet

> *Là encore, utilisez le [**mémo**](../../../memo/rocky_network.md) pour l'ajout de la route par défaut.*

Toutes les machines peuvent se joindre, et ont un accès internet. Yay.

![The siiize](../img/routing_table.jpg)

## Potit bilan

➜ Une fois cette section terminée, vous savez interconnecter autant de réseaux que nécessaires, de façon statique :

- **les routeurs sont l'élément central** : ils permettent aux paquets d'un réseau de passer vers un autre
- **pour pouvoir communiquer avec un autre réseau B, une machine doit :**
  - avoir une IP dans un réseau A
  - connaître l'IP d'un routeur qui lui aussi est dans le réseau A : il agira comme passerelle pour la machine
  - indiquer dans la table de routage de la machine qu'il existe une route vers le réseau B, en passant par la passerelle du réseau A
- **peu importe qu'il y ait des réseaux intermédiaires entre A et B : la machine cliente n'a pas besoin de le savoir**, elle n'a besoin que de connaître sa passerelle !

> *En effet, dans notre exemple, aucune des machines du Réseau 1 ou du Réseau 2 ne peut joindre les IPs du Réseau 3. Pourtant des paquets transitent par ce réseau quand le Réseau 1 et le Réseau 2 échangent des paquets, ou même quand les memebres du Réseau 2 vont sur internet.*

On peut passer à la suite : [config des services réseau](../network_services/README.md).
