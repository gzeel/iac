# Linux

Deploy een server instance (geen desktop), deze handleiding gaat uit van Ubuntu. Wil je iets anders? Dan zul je sommige commando's anders moeten gebruiken.

## Pre-req
Via de Remote console zul je SSH aan moeten zetten op je systeem. Ik ga uit van een Ubuntu installatie. Kies je iets anders moet je de commando's soms aanpassen

```bash
sudo ssh-keygen -A
sudo systemctl enable --now ssh
```

Gebruik je Ubuntu ipv Debian dan moet je nog een firewall regel toevoegen
```bash
sudo ufw allow ssh
```

Log nu via ssh in op het systeem, gebruik bv Windows Terminal of Putty hiervoor.
Installeer de pakketten git en unzip op het systeem:

```bash
sudo apt install git unzip
```

## SSH

We gaan passwordless SSH logins gebruiken vanaf je laptop en ontwikkelmachine richting de VM's die je aan gaat maken.
Maak daarom een ssh keypair aan voor de student user (of voor een andere user die gaat gebruiken) op je Linux ontwikkel VM. We gebruiken een ED25519 key omdat deze kort is.

```bash
ssh-keygen -t ed25519
```

In de directory /home/student/.ssh staan nu 2 bestanden id_ed25519 en id_ed25519.pub. De private en public key. De inhoud van de public key komt straks in je terraform bestanden te staan, de private key blijft op het Linux ontwikkel systeem.
Het kan wel handig zijn om de private key ook te kopieren naar je eigen laptop. Dan kun je ook passwordless inloggen via een terminal of VSCode. Zet daarom deze private key file (en noem deze ook id_ed25519) in C:\Users\je gebruikersnaam\.ssh\ Dit kun je bijvoorbeeld doen door een nieuwe file in die directory te maken met de inhoud van de file /home/student/.ssh/id_ed25519

Zet vervolgens de inhoud van /home/student/.ssh/id_ed25519.pub in /home/student/.ssh/authorized_keys bijvoorbeeld dus zo:

```bash
student@ubuntu:~/.ssh$ cat authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILrR6mV+q99gQm6lngESrQqmuJymT5REwvH/osmtmxx7 student@lokale-laptop
```

Let op: het bestand /home/student/.ssh/authorized_keys moet alleen write rechten voor de owner hebben (tip: chmod 400 authorized_keys)


## Gitlab
Voor onze code gaan we de gitlab omgeving van Windesheim gebruiken. Ga in een browser naar gitlab.windesheim.nl en log in. Maak vervolgens een Personal Access Token aan en bewaar dit op een goeie plek (hint: password manager)

Voor onze ontwikkelomgeving hebben we een aantal bestanden nodig. Ook deze staan in een (publieke) repository.
Deze repository moet je clonen naar je ontwikkel systeem. Voer het volgende commando op je ontwikkelsysteem uit:
```bash
git clone https://gitlab.windesheim.nl/fe2157786/iac-files.git
```

Als er gevraagd om met je gegevens in te loggen, gebruik dan je Windesheim email en net gemaakte Personal Access Token als wachtwoord.

## Installatie OVFTool
In de bovenstaande Git repo vind je een directory files. Daarin staat een installatie bestand voor OVFTool.
Voer de volgende commando's uit vanuit de iac-files/files directory:

```bash
unzip VMware-ovftool-<versie>-lin.x86_64.zip
```
In de nieuwe directory doe je het volgende :

```bash
sudo mv ovftool vmware-ovftool
```
```bash
sudo mv vmware-ovftool /usr/bin/
```
```bash
sudo chmod +x /usr/bin/vmware-ovftool/ovftool.bin
```
```bash
sudo chmod +x /usr/bin/vmware-ovftool/ovftool
```
Voer nu het volgende commando uit, als je een andere gebruiker dan de default user 'student' gebruikt moet je dit aanpassen.
```bash
sed -i '$ a\PATH=$PATH:/home/student/.local/bin:/usr/bin/vmware-ovftool' ~/.bashrc
```

## PIP

We installeren Ansible via PIP. Daardoor is het noodzakelijk dat PIP op het systeem staat.

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common python3-pip
```

## Terraform

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

```bash
sudo apt-get update && sudo apt-get install terraform
```

## Ansible

Wanneer pip succesvol is geinstalleerd kan Ansible worden geinstaleerd.
```bash
python3 -m pip install ansible --break-system-packages
```

Log als laatste actie uit en weer opnieuw in.