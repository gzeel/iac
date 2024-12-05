# VSCode

Extensions > Ansible Extension

Extensions > Remote SSH extension
Selecteer Remote Explorer voor een nieuwe SSH connectie

## SSH-key authenticatie
Open een commando shell en genereer een ssh-key

```bash
ssh-keygen -t ed25519
```

De passphrase mag leeg blijven. Nu zou je in c:\users\%username%\.ssh een id_ed25519.pub bestand moeten hebben.
De inhoud van dit bestand moet je toevoegen aan de file authorized_keys in /home/username/.ssh
Zorg dat de rechten van dit authorized_keys bestand goed (alleen lezen eigenaar) staan.

```bash
chmod 400 /home/%username%/.ssh/authorized_keys
```

Check nu of je zonder wachtwoord kunt inloggen.
Als dit niet werkt moet je op je ontwikkelmachine c:\users\%username%\.ssh\config aanpassen zodat de juiste identityfile gebruikt wordt:

```ini
Host 192.168.31.4
  HostName 192.168.31.4
  User henk
  IdentityFile "C:\Users\%username%\.ssh\id_ed25519"
```