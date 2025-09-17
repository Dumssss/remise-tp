## Proof proof proof

🌞 **Avec une commande `az`, afficher le *secret***

```bash
az keyvault secret show --name "mon-secret" --vault-name "dums-vault-2025" --query value -o tsv
```

🌞 **Depuis la VM, afficher le secret**

```bash
sudo apt-get install jq -y

TOKEN=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H 'Metadata: true' | jq -r .access_token)

curl 'https://dums-vault-2025.vault.azure.net/secrets/mon-secret?api-version=7.0' -H "Authorization: Bearer $TOKEN" | jq -r .value
```