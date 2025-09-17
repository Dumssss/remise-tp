## 3. Proooooooofs

🌞 **Prouvez que tout est bien configuré, depuis la VM Azure**

```bash
sudo mkdir /opt/azcopy
wget https://aka.ms/downloadazcopy-v10-linux -O azcopy_linux_latest.tar.gz
tar -zxvf azcopy_linux_latest.tar.gz
sudo cp azcopy_linux_amd64_*/azcopy /usr/local/bin/
```
```bash
azcopy login --identity
```
```bash
echo "Hello Blob Storage!" > testfile.txt
```
```bash
azcopy cp "testfile.txt" "https://dumsblobaccount.blob.core.windows.net/dums-container/testfile.txt"
```
```bash
mkdir download
cd download
azcopy cp "https://dumsblobaccount.blob.core.windows.net/dums-container/testfile.txt" .
```

🌞 **Déterminez comment `azcopy login --identity` vous a authentifié**

```txt
L'authentification s'est faite grâce à une Identité Managée assignée à la machine virtuelle.
En interne, azcopy login --identity a contacté le service Azure IMDS (Instance Metadata Service) sur une adresse IP spéciale (169.254.169.254) pour obtenir un JSON Web Token (JWT). Ce token a été généré par Azure et est un justificatif d'identité temporaire pour la machine virtuelle. Le rôle que tu as configuré avec Terraform (Storage Blob Data Contributor) a donné à cette identité managée les autorisations nécessaires pour accéder au conteneur de stockage, ce que le JWT certifie.
```

🌞 **Requêtez un JWT d'authentification auprès du service que vous venez d'identifier, manuellement**

```bash
curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fstorage.azure.com%2F' -H 'Metadata: true'
```

🌞 **Expliquez comment l'IP `169.254.169.254` peut être joignable**

```txt
L'adresse IP 169.254.169.254 est une adresse link-local non routable. . Elle n'est accessible que depuis la machine virtuelle elle-même, et non depuis Internet. Le système d'exploitation de la VM a une règle de routage spécifique qui redirige les paquets destinés à cette adresse vers le service Azure IMDS (Instance Metadata Service) de l'hôte sous-jacent. C'est une porte dérobée sécurisée qui permet à la VM de communiquer avec la plateforme Azure pour obtenir des informations (comme des métadonnées ou des JWT d'authentification) sans avoir besoin d'un accès internet public.
```
