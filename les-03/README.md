# Les 3 - Hello, Ansible (1)!

Datum: 

Leerdoelen:
1. Aan het einde van deze les weet je wat Ansible is en welke relatie het heeft met de theorie van Infrastructure as Code.
2. Aan het einde van deze les kun je een aantal ad-hoc commando's op een host uitvoeren
3. Aan het einde van deze les kun je een simpel playbook schrijven en dit uitvoeren op een groep van hosts dmv een inventory.

Inhoud:

  - Introductie Ansible
  - Inventory
  - Adhoc commando's
  - Playbooks
  - My first playbook
  - Opdracht
  - Waar hulp te krijgen?

## Introductie Ansible

Denk er eens hoe je in een vorig vak vak of project een server hebt geconfigureerd. Commando's met de hand uitgevoerd, alle machines uniek geconfigureerd, lastig 1:1 na te maken omdat je misschien geen documentatie van uitgevoerde commando's of bash scripts hebt bijgehouden.
Hoe handig zou het zijn als je in een taal of tool vast kan leggen hoe een server geconfigureerd moet worden qua geinstalleerde applicaties of inrichting?

Ansible kan je daarbij helpen. Ansible is een open-source softwaretool die wordt gebruikt voor het automatiseren van IT-taken, zoals het implementeren van applicaties, configuratiebeheer en het beheren van infrastructuur. Het werkt met een eenvoudige, mens- en machineleesbare taal genaamd YAML om beschrijvingen van IT-infrastructuren en -toepassingen te maken. Wat Ansible uniek maakt, is dat het geen agentsoftware vereist op de systemen die het beheert; het communiceert via SSH. Dit maakt het eenvoudiger in vergelijking met andere automatiseringshulpmiddelen zoals Puppet en Chef. Ansible zorgt ook voor idempotentie, wat betekent dat taken meerdere keren zonder bijwerkingen kunnen worden uitgevoerd, waardoor de systemen in dezelfde toestand blijven. 

Ansible werkt zoals gezegd via SSH, wat betekent dat het van nature private/public key-authenticatie kan gebruiken.
Werken met een private/public key in Ansible biedt belangrijke voordelen op het gebied van beveiliging, gemak en automatisering. Private/public key-authenticatie is veiliger dan wachtwoorden omdat de privésleutel nooit over het netwerk wordt verzonden en alleen de publieke sleutel op de servers wordt geplaatst, wat het risico op afluisteren of diefstal van wachtwoorden vermindert.

Daarnaast zorgt key-based authenticatie ervoor dat de noodzaak om telkens een wachtwoord in te voeren verdwijnt, wat het beheer vereenvoudigt. Dit is vooral handig bij het automatiseren van taken met Ansible, omdat scripts en playbooks zonder menselijke tussenkomst kunnen worden uitgevoerd. Het schalingsgemak wordt vergroot doordat publieke sleutels eenvoudig naar nieuwe servers kunnen worden gedistribueerd en oude sleutels kunnen worden verwijderd wanneer een medewerker vertrekt, zonder de noodzaak om wachtwoorden op meerdere systemen te wijzigen.

## Inventory

Ansible gebruikt een inventorybestand (eigenlijk een lijst met servers) om met servers te communiceren. Net als een hosts-bestand (denk aan /etc/hosts) dat IP-adressen koppelt aan domeinnamen (fqdn), koppelt een Ansible-inventorybestand servers (IP-adressen of domeinnamen) aan groepen. Inventorybestanden kunnen veel meer, maar voor nu maken we gewoon een eenvoudig bestand met één server. Maak een bestand met de naam inventory in een testprojectmap (hint, maak een repository op gitlab en clone deze naar je lokale systeem)

Namen van inventorybestanden hoeven geen bepaalde naamgevingsconventie te volgen. Ik gebruik vaak de bestandsnaam inventory voor de standaard 'ini-stijl'-syntax van Ansible, maar je kunt bv ook hosts.ini (met bestandsextensie gebruiken.

Bewerk deze hosts file met een editor (in ons geval VScode) en zet de volgende regels er in:

```ini
[example]
www.example.com
```

waarbij example de groep servers is die je beheert en www.example.com de domeinnaam (of het IP-adres) is van een server in die groep. Als je poort 22 niet gebruikt voor SSH op deze server, moet je deze toevoegen aan het adres, zoals www.example.com:2222, aangezien Ansible standaard poort 22 gebruikt en deze waarde niet krijgt van je ssh-configuratie bestand.

Je kunt je inventory ook in het globale inventorybestand van Ansible plaatsen, /etc/ansible/hosts, en elk playbook zal daar standaard naar verwijzen als er geen andere inventory is gespecificeerd. Dat bestand vereist echter sudo-rechten en het is meestal beter om een losse inventory bij te houden in je Ansible-projecten.

## Adhoc commando's

Nu je Ansible hebt geïnstalleerd en een inventorybestand hebt gemaakt, is het tijd om een opdracht uit te voeren om te zien of alles werkt! Voer het volgende in de terminal in (we doen iets veiligs zodat er geen wijzigingen op de server worden aangebracht):

```bash
ansible -i inventory example -m ping -u [username]
```

waarbij [username] de gebruiker is die je gebruikt om in te loggen op de server. Als alles werkte, zou je een bericht moeten zien als www.example.com | SUCCES >>, en dan het resultaat van je ping. Als het niet werkt, voer je de opdracht opnieuw uit met -vvvv aan het einde om uitgebreide uitvoer te zien. De kans is groot dat je SSH-sleutels niet correct hebt geconfigureerd. Als je inlogt met ssh gebruikersnaam@www.example.com en dat werkt, zou het bovenstaande Ansible-commando ook moeten werken.

Ansible gaat ervan uit dat je een wachtwoordloze (sleutelgebaseerde) login gebruikt voor SSH (je logt bijvoorbeeld in door ssh gebruikersnaam@example.com in te voeren en hoeft geen wachtwoord te typen). Als je per se wachtwoorden wil gebruiken, voeg dan de vlag --ask-pass (of -k) toe aan Ansible-opdrachten (mogelijk moet je ook het sshpass-pakket installeren om dit te laten werken).

Laten we nog een commando proberen wat je meer info geeft :

```bash
ansible -i inventory example -a "free -h" -u [username]
```

Wat gebeurd er hier?

## Playbooks

Het is natuurlijk niet handig als je een aantal van dit commando's achter elkaar uit moet voeren. Zeker niet als het handmatig moet. Ansible heeft hier als oplossing playbooks voor. De vertaling draaiboek pas er heel goed bij. In het draaiboek staan de taken beschreven die Ansible (achter elkaar) uit moet voeren.

Een Ansible Playbook is geschreven in YAML-formaat, wat een menselijk leesbare en machine-verwerkbare taal is. Het Playbook bestaat uit een reeks van 'plays', die elk bestaan uit een of meer 'tasks'. Elke taak beschrijft een specifieke actie die moet worden uitgevoerd, zoals het installeren van software, het aanpassen van configuratiebestanden, het controleren van de status van een dienst, en meer. Deze taken kunnen ook variabelen, voorwaardelijke verklaringen (conditions) en lussen (loops) bevatten om de automatisering flexibel en aanpasbaar te maken voor verschillende scenario's.

Een voorbeeld playbook:

```yaml
 1 ---
 2 - hosts: all
 3   become: yes
 4 
 5   tasks:
 6   - name: Ensure chrony (for time synchronization) is installed.
 7     yum:
 8       name: chrony
 9       state: present
10 
11   - name: Ensure chrony is running.
12     service:
13       name: chronyd
14       state: started”
```

Wat zou dit playbook doen?
Laten we er stap voor stap door heen gaan:

```yaml
1 ---
```

Deze eerste regel is een markering die aangeeft dat de rest van het document zal worden opgemaakt in YAML.

```yaml
2 - hosts: all
```

Deze regel vertelt Ansible op welke hosts dit draaiboek van toepassing is. Hier wordt aangegeven dat het op alle hosts uit de opgegeven inventory uitgevoerd moet worden.

```yaml
3 - become: yes
```

Omdat we root toegang nodig hebben om chrony te installeren en de systeemconfiguratie te wijzigen, vertelt deze regel Ansible om sudo te gebruiken voor alle taken in het draaiboek (je vertelt Ansible om de rootgebruiker te 'worden' met sudo, of een equivalent).

```yaml
5 tasks:
```

Nu volgt de opsomming van taken die uitgevoerd moeten worden. Alle taken na deze regel worden uitgevoerd op alle hosts (want hosts was all)

```yaml
6   - name: Ensure chrony (for time synchronization) is installed.
7     yum:
8       name: chrony
9       state: present”
```

Deze opdracht is hetzelfde als het uitvoeren van yum install chrony, maar het is veel intelligenter; het zal controleren of chrony is geïnstalleerd, en zo niet, installeer het dan. Je zou dit ook kunnen doen met het volgende shellscript:

```bash
if ! rpm -qa | grep -qw chrony; then
    yum install -y chrony
fi
```

Het bovenstaande script is echter nog steeds niet zo robuust als het yum-commando van Ansible. Wat als een ander pakket met chrony in zijn naam is geïnstalleerd, maar niet chrony? Dit script zou extra aanpassingen en complexiteit vereisen om overeen te komen met het eenvoudige Ansible yum-commando.

```yaml
11   - name: Ensure chrony is running.
12     service:
13       name: chronyd
14       state: started
15       enabled: yes
```

Deze laatste taak controleert en zorgt ervoor dat de chronyd-service wordt gestart en uitgevoerd, en stelt deze in om te starten bij het opstarten van het systeem. Een shellscript met hetzelfde effect zou zijn:

```bash
# Start chronyd if it's not already running.
if ps aux | grep -q "[c]hronyd"
then
    echo "chronyd is running." > /dev/null
else
    systemctl start chronyd.service > /dev/null
    echo "Started chronyd."
fi
# Make sure chronyd is enabled on system startup.
systemctl enable chronyd.service
```

Hier zie je hoe de dingen ingewikkeld worden in het land van shell-scripts! En dit shellscript is nog steeds niet zo robuust als wat je krijgt met Ansible. Om idempotentie te behouden en foutcondities af te handelen, moet je nog meer werk doen met eenvoudige shellscripts dan met Ansible.

We zouden beknopter kunnen zijn (en de krachtige eenvoud van Ansible demonstreren) en de zelfdocumenterende naamparameter en verkorte sleutel=waarde-syntaxis van Ansible negeren, resulterend in het volgende playbook:

```yaml
1 ---
2 - hosts: all
3   become: yes
4   tasks:
5   - yum: name=chrony state=present
6   - service: name=chronyd state=started enabled=yes
```
Net als bij code- en configuratiebestanden is documentatie in Ansible (bijvoorbeeld het gebruik van de name-parameter en/of het toevoegen van opmerkingen aan de YAML voor gecompliceerde taken) niet absoluut noodzakelijk. Maar zorg ervoor dat je taken een logische naam hebben met wat ze doen. Dit helpt ook wanneer je de playbooks moet overdragen, zodat je kunt laten zien wat er gebeurt in een voor mensen leesbaar formaat.



## Voorbeeld

Om het wat complexer te maken gaan we werken met een voorbeeld met 2 applicatie of webservers en een database server.
Hiervoor is het dus nodig dat je een terraform bestand maakt wat deze servers aanmaakt. Pak het voorbeeld bestand uit les 2 erbij, en bedenk wat je zou moeten doen om meerdere vm's vanuit 1 Terraform bestand te kunnen deployen.

```terraform
resource "esxi_guest" "vmtest" {
  guest_name         = "vmtest"
  disk_store         = "datastore1"

  ovf_source = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.ova"
  network_interfaces {
    virtual_network = "VM Network"
  }
}
```

Er zijn veel manieren waarop je Ansible kunt vertellen over de servers die je beheert, maar de meest standaard en eenvoudigste is om ze toe te voegen aan een inventorybestand dat je opslaat in de directory van je Ansible-project.

In de eerdere voorbeelden specificeerden we het pad naar het inventarisbestand op de opdrachtregel met behulp van -i hosts.ini. Maar we kunnen voorkomen dat we dit pad telkens moeten specificeren als we ansible-opdrachten uitvoeren door het pad naar het inventorybestand op te geven in een ansible.cfg-bestand dat ook is opgeslagen in de hoofdmap van je project:

```ini
1 [defaults]
2 inventory = hosts.ini
```

Maak nu een hosts.ini bestand in de directory van je project, zie hieronder voor een voorbeeld:

```ini
 1 # Application servers
 2 [app]
 3 app-server1 ansible_host=192.168.60.4
 4 app-server2 ansible_host=192.168.60.5
 5 
 6 # Database server
 7 [db]
 8 database-server1 ansible_host=192.168.60.6
 9 
10 # Group 'multi' with all servers
11 [multi:children]
12 app
13 db
14 
15 # Variables that will be applied to all servers
16 [multi:vars]
17 ansible_user=ansible
18 ansible_ssh_private_key_file=~/.ssh/skylab
```

Laten we nog een keer stap voor stap door dit bestand lopen.

1. Het eerste blok plaatst beide applicatieservers in het [app] blok.
2. Het tweede blok plaats de database server in het [db] blok.
3. Het derde blok definieert een nieuwe groep [multi] met 'child' groepen, en deze child groepen zijn de app en db blokken
4. Het vierde blok geeft een aantal variabelen aan alle servers in de groep 'multi'.

Laten we nu kijken of de hostname van alle vm's juist is geconfigureerd met een Ansible ad-hoc commando :

```bash
ansible multi -a "hostname"
```

Wordt het commando zoals verwacht, en in de verwachte volgorde(!) uitgevoerd? Herhaal het commando nog eens? Zie je dat de volgorde veranderd?

Ansible voert je opdrachten standaard parallel uit, met behulp van meerdere procesforks, zodat de opdracht sneller wordt voltooid. Als je een paar servers beheert, is dit misschien niet veel sneller dan de opdracht serieel uitvoeren, op de ene server na de andere, maar zelfs als je 5-10 servers beheert, zul je een dramatische versnelling merken als je Ansible's parallellisme gebruikt.

Voer hetzelfde commando nog maar een keer uit, maar voeg deze keer het argument -f 1 toe om Ansible te vertellen om slechts één fork te gebruiken (in feite om het commando achtereenvolgens op elke server uit te voeren):

```bash
ansible multi -a "hostname" -f 1
```

Probeer hetzelfde maar eens met de commando's voor het geheugen gebruik (free -m) en diskspace (df -h)

Nu we deze inventory hebben kunnen we ook playbooks uitvoeren op de verschillende hosts.
Stel, we willen op de web/app servers een bepaald pakket (chrony) geinstalleerd hebben en op de database servers wat anders (curl). Dan kun je met hosts aangeven op welke groep servers je de taken uitgevoerd wil hebben:

```yaml
---
- hosts: app
  become: true

  tasks:
  - name: Ensure chrony is installed
    apt:
      name: chrony
      state: present

  - name: Ensure chrony is started
    service:
      name: chronyd
      state: started
      enabled: true
```
en

```yaml
---
- hosts: db
  become: true

  tasks:
  - name: Ensure curl is installed
    apt:
      name: curl
      state: present
```

Als je dit in 1 playbook samen zou willen uitvoeren ziet het playbook het er als volgt uit:

```yaml
---
- hosts: app
  become: true

  tasks:
  - name: Ensure chrony is installed
    apt:
      name: chrony
      state: present

  - name: Ensure chrony is started
    service:
      name: chronyd
      state: started
      enabled: true

- hosts: db
  become: true

  tasks:
  - name: Ensure curl is installed
    apt:
      name: curl
      state: present
```

Het playbook kun je uitvoeren met het volgende commando:

```bash
ansible-playbook -i inventory playbook.yml
```

> Opdrachten
> - Deploy met Terraform een VM en zorg dat je in kunt loggen met je user dmv een ssh-key (hint cloudinit uit de vorige les) Maak een inventory voor deze vm
> - Voer enkele ad-hoc commando's op deze vm uit, bv ping, hostname, apt update etc
> - Maak een playbook wat alle packages op je vm update.  
> - Maak een playbook om een regel toe te voegen in /etc/hosts toe die naar je esxi server wijst. Noem de host esxi.
> - Maak een playbook die een user test toevoegt op een systeem
> - Maak een playbook wat het pakket fail2ban installeert op je vm. Gebruik de volgende configuratie (dit moet als configuratiebestand aanwezig zijn op je vm):
> ```ini
> [sshd]
> enabled = true
> bantime = 3600
> ```
> - Maak een playbook dat van je vm de beschikbare diskspace ophaalt.
> - Doe het zelfde als bij opdracht 1 maar dan met 3 vm's en zorg dat de inventory automatisch gemaakt wordt. Denk aan terraform output en het ophalen van het IP. Nu moet je het dus in een bestand krijgen. Bekijk de voorgaande lessen eens hoe je dat zou kunnen doen. De playbooks van opdracht 3 t/m 6 moeten op alle 3 de systemen uitgevoerd worden. (NB Je mag nog, met aftrek van 0.2p, de IP's van de 3 VM's statisch als in dat je specifiek opgeeft van welke vm's het ip adres moet worden opgehaald, in de inventory terecht laten komen, maar je zou eigenlijk het al anders moeten kunnen (bv met een template of for loop)). 
