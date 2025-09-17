## Adapter le plan Terraform

🌞 **Proofs ! Donnez moi :**

- la sortie du `terraform apply` (ce qu'affiche votre `outputs.tf`)
```bash
terraform apply

...
Plan: 0 to add, 1 to change, 0 to destroy.
...
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
...
Apply complete! Resources: 1 changed.

Outputs:

public_ip_address = "***.***.***.***"
vm_dns_name = "dums-tp2-vm.uksouth.cloudapp.azure.com"
```
- une commande `ssh` fonctionnelle vers le nom de domaine (pas l'IP)

```bash
ssh dums@dums-tp2-vm.uksouth.cloudapp.azure.com
```