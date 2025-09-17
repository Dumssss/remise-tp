# Monitoring

## Proofs

### A. Voir les alertes avec `az`

🌞 **Une commande `az` qui permet de lister les alertes actuellement configurées**

```bash
az monitor alert show --resource-group dums-group --name "cpu-alert-super-vm"

az monitor alert show --resource-group dums-group --name "ram-alert-super-vm"
```

### B. Stress pour *fire* les alertes

🌞 **Stress de la machine**

```bash
sudo apt-get update && sudo apt-get install stress-ng -y

```
```bash
stress-ng --cpu 0 --timeout 600s &

stress-ng --vm 1 --vm-bytes 1G --timeout 600s &
```

🌞 **Vérifier que des alertes ont été *fired***

```bash
az monitor activity-log list --resource-group dums-group --start-time $(date -u -d '1 hour ago' +'%Y-%m-%dT%H:%MZ')
```