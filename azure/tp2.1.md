## 2. Ajouter un NSG au déploiement

???+ danger

    Si vous faites le TP à l'école, on parle donc de l'IP publique du routeur de l'école.  
    Si c'est chez vous, ce sera celle de votre box.  
    **Il serait bien avisé de masquer cette IP dans le compte-rendu de TP public que vous me remettez.**  

## 3. Proofs !

🌞 **Prouver que ça fonctionne, rendu attendu :**

- la sortie du `terraform apply`
```bash
terraform apply

...
Plan: 2 to add, 0 to change, 0 to destroy.
...
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
...
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```
- une commande `az` pour obtenir toutes les infos liées à la VM

```bash
az network nic show --resource-group dums-group --name vm-nic
```
```json
"networkProfile": {
  "networkInterfaces": [
    {
      "id": "/subscriptions/.../networkInterfaces/nic-dums",
      "primary": true,
      "resourceGroup": "dums-group"
    }
  ]
},
"publicIps": "***.***.***.***"
```
```bash
sudo nano /etc/ssh/sshd_config
sudo systemctl restart sshd

ss -tlpn | grep 2222
LISTEN 0      128         0.0.0.0:2222       0.0.0.0:* users:(("sshd",pid=1234,fd=3))
LISTEN 0      128            [::]:2222          [::]:* users:(("sshd",pid=1234,fd=4))
```

```PS
ssh -p 2222 dums@***.***.***.****
ssh: connect to host ***.***.***.**** port 2222: Connection timed out
```