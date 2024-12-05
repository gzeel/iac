# Les 2 - Hello, Terraform!

Datum: 

Leerdoelen:
1. Aan het einde van deze les weet je wat Terraform is en welke relatie het heeft met de theorie van Infrastructure as Code.
2. Aan het einde van deze les weet je wat CloudInit is en welke relatie het heeft met de theorie van Infrastructure as Code.
3. Aan het einde van deze les weet je hoe je een virtuele machine door middel van code kunt deployen en starten met daarop een initiele configuratie.

Inhoud:

  - Recap week 1
  - Introductie in Terraform
  - Waarom Terraform?
  - Cloud Init
  - Waar hulp te krijgen
  - Opdracht

## Recap week 1

Vorige keer hebben we gekeken naar wat Infrastructure as Code is, waarom we het gebruiken en wat de Key Principes zijn.
Herinneren jullie je de termen Declarative, Immutable en Idempotency nog?
## Introductie in Terraform

In deze les gaan we kennismaken met Terraform als tool voor Infrastructure as Code (IaC). We gaan het hebben over waarom Terraform wordt gebruikt, de voor- en nadelen en je krijgt een gedetailleerde uitleg over het opstellen van een Terraform-bestand met stapsgewijze voorbeelden voor het implementeren van resources in Microsoft Azure. Je gaat daarna zelf aan de slag met Terraform in combinatie met ESXi en/of Azure.

## Waarom Terraform?

Schaalbaarheid en Herbruikbaarheid: Terraform stelt ontwikkel/beheerteams in staat om infrastructuur op te zetten en te beheren op een consistente en herhaalbare manier. Het stelt beheerders en ontwikkelaars in staat om infrastructurele componenten te definiëren als code, waardoor ze kunnen profiteren van versiebeheer, samenwerking en hergebruik.
Multi-Cloud en Hybride Cloud: Terraform is cloudplatformonafhankelijk en ondersteunt meerdere cloudproviders. Het maakt het mogelijk om infrastructurele resources te beheren in verschillende cloudomgevingen en zelfs on-premises.
Voorspelbaarheid en Documentatie: Het gebruik van Terraform verhoogt de voorspelbaarheid van implementaties omdat de infrastructuur als code wordt vastgelegd. Het biedt ook ingebouwde documentatie van de infrastructuurconfiguratie.
Doelgroep:
Ontwikkelaars, systeembeheerders en DevOps-teams die verantwoordelijk zijn voor het beheren van infrastructuur.

Voor dit vak gaan we Azure en een ESXi server gebruiken die jullie hebben ingericht op Skylab. Standaard kan Terraform wel met Azure maar niet met ESXi 'praten'. Wel met VMWare vCenter, maar omdat dat dit vak onnodig complex maakt houden we het hiervoor bij ESXi. Als Terraform niet standaard met iets kan praten gebruik je een custom provider plugin. Omdat we deze (custom) provider plugin gebruiken moeten we deze ergens in de code bekend maken. Dat kan in een los providers.tf bestand maar je mag het ook (bovenin) je main.tf bestand zetten:

```terraform
terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
  }
}
```

Deze provider heeft informatie nodig waar de ESXi server te vinden is waar je tegenaan wil praten. We hebben dus een blok 'provider' nodig. In dit blok geef je onder andere het IP adres op, welke user gebruikt moet worden e.d. Let op, dit is niet bij elke provider hetzelfde. Vaak kun je in de documentatie van een provider informatie vinden hoe zo'n blok eruit moet zien.
Voor de josenk/esxi provider kan het er alsvolgt uitzien:

```terraform
# Details voor de provider
provider "esxi" {
  esxi_hostname      = "192.168.100.84" #vul hier jouw ESXi IP nummer in
  esxi_hostport      = "22"
  esxi_hostssl       = "443"
  esxi_username      = "root"
  esxi_password      = "Welkom01!"
}
```

Terraform weet nu waar we iets willen gaan doen en met welke provider. Maar nog niet dat we deze VM willen maken hoe deze VM eruit moet gaan zien. Welke virtuele hardware wil je in de VM stoppen?
Daar moeten we een 'resource' voor aanmaken in het bestand. Deze resource krijgt een naam en je kunt aangeven hoeveel cpu's, memory en storage je resource moet krijgen. Ook kun je bijvoorbeeld aangeven welk netwerk er gekoppeld moeten worden.

```
resource "esxi_guest" "vmtest" {
  guest_name         = "vmtest"
  disk_store         = "datastore1"

  ovf_source = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.ova"
  network_interfaces {
    virtual_network = "VM Network"
  }
}
```

Je ziet ook de regel ovf_source staan. Dit is een verwijzing naar een image wat Terraform moet gebruiken om de VM mee aan te maken. Terraform zal deze .ova file omzetten in een disk voor de VM. De VM gebruikt dit uiteindelijk als boot en data disk. In dit image zit een complete Ubuntu 22.04 server VM.

Uiteindelijk ziet de file er dan ongeveer alsvolgt uit :

```terraform
# Provider info
terraform {
  required_version = ">= 0.13"
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
    }
  }
}

# Details voor de provider
provider "esxi" {
  esxi_hostname      = "192.168.100.84" #vul hier jouw ESXi IP nummer in
  esxi_hostport      = "22"
  esxi_hostssl       = "443"
  esxi_username      = "root"
  esxi_password      = "Welkom01!"
}

# De resource die je aan gaat maken
resource "esxi_guest" "vmtest" {
  guest_name         = "vmtest"
  disk_store         = "datastore1"

  ovf_source = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.ova"
  network_interfaces {
    virtual_network = "VM Network"
  }
}
```

#### Uitvoeren
Als je een configuratie gemaakt hebt zijn er 3 belangrijke commando's voor het gebruik van Terraform.

Als eerste moet je ervoor zorgen dat je provider beschikbaar is en dat een aantal files klaar worden gezet.
Dat doe je met 

```bash
terraform init
```

Wil je vervolgens de deployment van de VM's gaan uitvoeren, dan kun je dat doen met:
```bash
terraform apply
```

Zoals je ziet krijg je vlak voor het uitvoeren van de deployment nog een yes/no vraag. Deze kun je eventueel overslaan door --auto-approve toe te voegen aan je commando:
```bash
terraform destroy --auto-approve
``` 

## Cloudinit

In bovenstaand voorbeeld hebben we het default 'Cloud' image van Ubuntu gedeployed op onze ESXi omgeving.
Cloud images hebben een minimalistische configuratie en zijn redelijk klein in omvang (ongeveer 700mb). Ze zijn met name bedoeld voor public cloud omgevingen zoals Amazon's EC2 of een Azure omgeving.

Om gebruik te kunnen maken van dit cloud image moeten we het na deployment op de een of andere manier configureren want het heeft bijvoorbeeld geen wachtwoord voor de default gebruiker.

De tool die gebruikt wordt om een image na deployment te configureren heet CloudInit. CloudInit maakt gebruik van twee yaml bestanden, metadata.yaml waarin gegevens over het systeem komen zoals hostname, netwerk informatie e.d. en een bestand userdata.yaml waar gegevens over de aan te maken gebruiker, te installeren packages etc komen.

In onderstaand voorbeeld zie je hoe je met een file userdata.yaml een user aan kunt maken op het systeem en hoe je een public key die je eerder aangemaakt hebt op het systeem zet. Hierdoor kun je door de combinatie van private key (op jouw systeem) en public key (op de vm) zonder wachtwoord inloggen op de vm. De userdata.yaml file kun je ook gebruiken om bijvoorbeeld packages te installeren. 

metadata.yaml
```yaml
#cloud-config
local-hostname: vm-host-naam
```

userdata.yaml
```yaml
#cloud-config
users:
  - name: username_die_je_aan_wil_maken
    ssh-authorized-keys:
      - ssh-ed25519 je_ssh_public_key
    shell: /bin/bash
```

Je kunt voor de waardes van de keys (bv name, local-hostname) ook variabelen gebruiken vanuit een variabele bestand (zie bv het simple-variables voorbeeld).

Om cloudinit aan te roepen na het deployen van de VM door Terraform moet je een blok ```guestinfo``` opnemen binnen de resource in je Terraform bestand. Dit is voor elke provider anders, maar de josenk/esxi provider verwacht 4 regels met data. In deze 4 regels staat de locatie van metadata.yaml, userdata.yaml en voor elk van deze files de codering die Terraform moet gebruiken (base64).

```yaml
  guestinfo = {
    "metadata"          = base64encode(templatefile("metadata.yaml", { 
      name = format("webserver")
    }))
    "metadata.encoding" = "base64"
    "userdata"          = base64encode(templatefile("userdata.yaml", local.templatevars))
    "userdata.encoding" = "base64"
  }
```

Waarbij userdata.yaml je template bestand is wat je gebruikt en local.templatevars een setje lokale variabelen in het terraform bestand. Cloudinit verwacht een base64 encoded bestand, vandaar de base64encode functie ervoor. De variabelen die je in je userdata.yaml bestand gebruikt haal je ook vanuit je Terraform variabelen. Meer info over Guestinfo voor de ESXi provider kun je vinden in de documentatie van de ESXi provider.

Let er op dat op de eerste de regel ```#cloud-config``` in beide files staat. Anders zal cloudinit de file niet gebruiken!

## Terraform Output
Zoals je in de voorbeelden kunt vinden kun je tijdens het deployen van je infrastructuur Terraform ook output laten genereren. Bijvoorbeeld een bestand met daarin de IPs van de vm's die je net gedeployed hebt. Er zijn daar een aantal opties voor. Een daarvan is het gebruik van template files. Een template file is een bestand wat je vooraf maakt, waar bepaalde variabelen in staan die worden vervangen tijdens het uitvoeren van de resource. In dit geval kun je dat aanroepen door een local_file resource (Want je wil een lokaal bestand aanmaken) in je terraform file op te nemen.

Zie hier voor [De terraform templatefile documentatie](https://developer.hashicorp.com/terraform/language/functions/templatefile)

Een andere optie is het 'streamen' van tekst naar een file. Dit doe je doormiddel van de EOF functie. Zie deze [site](https://medium.com/@rajeshshukla_49087/ansible-inventory-file-using-terraform-b305db3ead2) voor een uitleg. Let erop dat bij de provider die wij gebruiken (josenk/esxi) informatie uit de vm resource kan worden gehaald door deze aan te roepen door bijvoorbeeld ```esxi_guest.dbserver``` te gebruiken met daarna de informatie die je wil hebben. Dus bijvoorbeeld ```esxi_guest.dbserver.ip_address``` of ```esxi_guest.dbserver.guest_name```. Als je meerdere vm's in 1 terraform bestand hebt kun je met een for loop werken, waarbij de gevonden ip's samengevoegd worden in het bestand, elk op een nieuwe regel. 

Template:
```
resource "local_file" "ip_file" {
  content  = templatefile("iplijst2.tpl", { ipAddresses = esxi_guest.dbserver[*].ip_address })
  filename = "iplijst2"
}
```

Templatefile:
```
%{ for ip in ipAddresses ~}
${ip}
%{ endfor ~}
```

EOF:
```
resource "local_file" "iplijst_output" {
  filename = "iplijst"
  content = <<EOF
${join("\n", [for instance in esxi_guest.dbserver : instance.ip_address] )}
EOF
}
```

In 2023 is er een extra mogelijkheid bijgekomen via een provider die gemaakt is door RedHat. Deze cloud.terraform provider heeft de mogelijkheid om een inventory voor je aan te maken. Je kunt er [hier](https://blog.sneakybugs.com/ansible-inventory-terraform/) meer over lezen.

Neem de voorbeelden niet maar zo 1:1 over, kijk goed wat er staat en pas het aan naar je eigen situatie.


## Opdrachten
> Opdracht 1 : Maak een terraform deployment file voor 1 Ubuntu VM met 1 vcpu en 1024MB geheugen. Je zult zien dat de VM start en dat via de remote console van ESXi een prompt kunt zien. Maar je kunt er nog niks mee.. Daarom mag je de VM verwijderen.

> Opdracht 2 : Maak een terraform deployment file waarin je in totaal 3 Ubuntu VM's deployed met 1 vcpu en 2048MB geheugen, met de volgende kenmerken:
> - Je hebt het Ubuntu 22.04 cloudimage gebruikt
> - Er is een resource voor 2 Ubuntu VM's die de naam webserver hebben
> - Er is een resource voor 1 Ubuntu VM die de naam databaseserver heeft.
> - Via cloudinit maak je op de 3 vm's een gebruiker aan met sudo rechten zonder dat er alsnog een wachtwoord wordt gevraagd.
> (De volgende criteria zoek je zelf op in de voorbeelden van de provider, zie voor de link hieronder)
> - Via cloudinit zet je je public ssh-key (let op gebruik je ED25519 key) op de 3 vm's gezet
> - Via cloudinit installeer je de packages wget en ntpdate. 
> - Het ip adres van elke machine komt in een bestand op je beheer systeem.
> 
> Gebruik hiervoor de voorbeelden in de IAC Git repository en de voorbeelden in de [Git Repository van de ESXI-terraform provider](https://github.com/josenk/terraform-provider-esxi/tree/master/examples)