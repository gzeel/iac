# Les 6
Leerdoelen:

1. Aan het einde van de les weet je wat Docker is
2. Aan het einde van deze les weet je hoe je via Ansible Docker containers kunt aanmaken en beheren.

## Docker

Docker is niet zozeer Infrastructure as Code als de tools waar we de afgelopen weken naar gekeken hebben. Maar het heeft wel veel voordelen als je met Infrastructure as Code gaat werken of als je als organisatie  richting een DevOps manier van werken wil.
Doordat een applicatie niet langer (handmatig) geinstalleerd wordt, met een rij aan handmatig op te lossen dependencies, zou je kunnen stellen dat het een soort van idempotency in zich heeft. 

Docker werkt met containers. Containerisatie is OS-gebaseerde virtualisatie die meerdere virtuele eenheden (processen) in userspace creëert. Containers delen dezelfde hostkernel, maar zijn van elkaar geïsoleerd via namespaces en mechanismen voor resourcecontrole op besturingssysteemniveau. Op containers gebaseerde virtualisatie biedt een ander abstractieniveau op het gebied van virtualisatie en isolatie in vergelijking met hypervisors zoals ESXi en HyperV. Hypervisors gebruiken veel hardware, wat resulteert in overhead in termen van virtualisatie van hardware en virtuele drivers. Een volledig besturingssysteem (bijvoorbeeld Linux, Windows) draait bovenop deze gevirtualiseerde hardware in elke virtuele machine-instantie.
Containers daarentegen draaien als processen op besturingssysteemniveau, waardoor dergelijke overhead wordt vermeden. Deze containers draaien bovenop dezelfde gedeelde besturingssysteemkernel van de onderliggende hostmachine en binnen elke container kunnen een of meer processen worden uitgevoerd. In containers hoeft je geen RAM vooraf toe te wijzen; het wordt dynamisch toegewezen tijdens het maken van een container, terwijl je bij VM's eerst het geheugen vooraf moet toewijzen en vervolgens de virtuele machine moet maken, denk aan wat je met Terraform gedaan hebt.

Containers kunnen vrijwel overal draaien en zijn zeer eenvoudig te ontwikkelen en te implementeren: op Linux-, Windows- en Mac-besturingssystemen; op virtuele machines of bare metal, op de machine van een ontwikkelaar of in datacenters op locatie; en natuurlijk in de publieke cloud. Containers virtualiseren CPU-, geheugen-, opslag- en netwerkbronnen op besturingssysteemniveau, waardoor ontwikkelaars een sandbox-weergave krijgen van het besturingssysteem, logisch geïsoleerd van andere applicaties.

Wil je meer leren over docker? Kijk dan hier : https://www.youtube.com/watch?v=eGz9DS-aIeY

## Installatie docker
Op de volgende pagina's kun je meer informatie vinden over het installeren van Docker op [Debian](https://docs.docker.com/engine/install/debian/) en [Ubuntu](https://docs.docker.com/engine/install/ubuntu/).

> Opdracht:
> -  Deploy met Terraform een VM op je ESXi server. Gebruik de informatie van bovenstaande pagina en schrijf een Ansible playbook dat de installatie van docker op deze VM automatiseert. Let op, de installatie moet via de docker PPA (repo) gaan, dus niet de default van Debian/Ubuntu.

## Beheer docker containers met Ansible
Als je (meerdere) Docker containers hebt draaien en beheert, weet je misschien hoe snel configuratiebeheer uit de hand kan lopen. Vooral als een van je services een eigen netwerk, synchronisatie van configuratiebestanden of enige andere voorafgaande voorbereiding nodig heeft.

Om het overzicht te bewaren zou je een bepaalde standaard aan kunnen houden. Deze zou er bijvoorbeeld zo uit kunnen zien:


- Elke service (container) heeft zijn eigen specifieke playbook.

Het hebben van een specifiek playbook per service zorgt voor een vastgelegde scope van die service, maakt het mogelijk om services individueel te starten, en het modulaire karakter biedt de mogelijkheid om eenvoudig meerdere diensten te combineren.

- Playbooks moeten worden vernoemd naar de service waarvoor ze verantwoordelijk zijn.

Het hebben van een voorspelbare naamgevingsconventie zorgt er voor dat in èèn oogopslag duidelijk is waar het playbook verantwoordelijk voor is.

- Services moeten doorgaans worden gedefinieerd als een Ansible role.

Zoals je eerder hebt gezien heeft het de voorkeur om complexere en herhaalbare taken in een role samen te voegen. (bijvoorbeeld:  meerdere containers die samenwerken, synchronisatie van configuratiebestanden, netwerken of enige vorm van voorbereiding). 

ℹ️ Bij wijze van uitzondering kunnen Ansible Roles overdreven zijn voor eenvoudige services waarvoor geen voorafgaande voorbereiding vereist is. Deze services kun je in een (simpel) playbook worden definieren.


Ansible heeft ook [diverse modules](https://docs.ansible.com/ansible/latest/collections/community/docker/index.html) om docker containers te beheren op een server.

Een voorbeeld om een Nginx image vanuit Docker Hub te downloaden (pull) en deze als container te deployen (run)
```yaml
---
- name: Deploy NGINX Docker container
  hosts: dockerhost
  become: true

  tasks:
    - name: Pull NGINX Docker image
      docker_image:
        name: nginx
        source: pull

    - name: Run NGINX Docker container
      docker_container:
        name: my_nginx
        image: nginx
        state: started
        ports:
          - "80:80"
```

> Opdracht: 
> - Gebruik bovenstaand voorbeeld en schrijf een playbook dat 2 nginx containers deployed. Maar zorg er wel voor dat ze tegelijkertijd kunnen werken en apart benaderbaar zijn. Zorg er voor dat de webservers een begroetingspagina laten zien met jouw studentnummer. Let op, de pagina moet vanaf een centrale plek op de host worden kunnen worden aangepast.

Je hebt nu een systeem dat 2 webservers bevat, maar we kunnen een gebruiker niet elke keer een specifieke container laten benaderen. Daarvoor bestaan er loadbalancers of reverse proxies. Je kunt nginx ook als reverse proxy inzetten. Deze zal het inkomende verkeer verdelen over de opgegeven backends (jouw eerder gedeployde webservers)

> Opdracht:
> -  Pas je playbook aan naar een role. Zorg dat je ook een nginx reverse proxy aanmaakt (Je zult dus iets met een configuratie bestand moeten doen, ga hiervoor opzoek in de nginx documentatie) die het verkeer over de 2 webserver verdeeld.
> - Schrijf een terraform bestand wat een VM aanmaakt op je ESXi server en na het deployen van deze VM automatisch bovenstaand playbook/role aanroept.
