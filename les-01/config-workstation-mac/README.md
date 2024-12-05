# MacOS Setup
MacOS heeft het voordeel dat het gebaseerd is op Unix/BSD, door gebruik te maken van de ingebouwde terminal (of vervanger zoals iterm2) hebben we niet zoiets als WSL nodig.

## Homebrew
Veel tools die we hierna installeren kunnen via HomeBrew geinstalleerd worden. Daarom moet eerst HomeBrew op het systeem aanwezig zijn.
Installeer het met het volgende commando:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## iTerm2 (optioneel)
iTerm2 is een terminal client met wat meer mogelijkheden dan de ingebouwde terminal client.
```zsh
brew install iterm2
```

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
Pak de zip file uit en installeer deze DMG op je systeem. Het kan zijn dat je permissies moet geven om deze op te mogen starten.

Voeg na installatie de volgende regel toe aan .zshrc in je home directory

```zsh
export PATH="$PATH:/Applications/VMware OVF Tool/"


## PIP
PIP hebben we nodig om Ansible te installeren.
```zsh
curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
```

## Ansible
Wanneer pip succesvol is geinstalleerd kan Ansible worden geinstaleerd.

```zsh
python3 -m pip install --upgrade pip
python3 -m pip install ansible
```

## Terraform
Voor de installatie van Vagrant gebruiken we ook weer brew

```zsh
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

## VScode
Om o.a. de Ansible code te kunnen bewerken is het handig als er een editor op je systeem staat. VSCode is een handige editor.

```zsh
brew install --cask visual-studio-code
```

