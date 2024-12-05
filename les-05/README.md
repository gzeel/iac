# les-05
Leerdoelen:

1. Aan het einde van de les weet je hoe je Ansible code via diverse methodes kunt testen
2. Aan het einde van deze les weet je wat een CI/CD Pipeline is en hoe je dit kunt toepassen in Gitlab.

## Ansible (3) Code testen

Wanneer je bezig bent een applicatie te ontwikkelen is het heel normaal dat je de software code test voordat je de applicatie in een productiomgeving beschikbaar maakt. We hebben de afgelopen weken besteed om onze infrastructuur ook als code te gaan zien. Waarom zouden we deze code dan niet testen?

We kunnen dezelfde manieren en methodes van software testing ook toepassen op infrastructuurcode. Denk dus aan unit, functionele, integratie en acceptatietesten.
Unit-testen, toegepast op applicaties, zijn het testen van de kleinste code-eenheden (meestal functies of klassenmethoden). In Ansible zouden unit-tests doorgaans van toepassing zijn op individuele draaiboeken. Je zou individuele draaiboeken in een geïsoleerde omgeving kunnen draaien, maar dat is vaak de moeite niet waard. Wat wel de moeite waard is, is controleren op playbook-syntax, om er zeker van te zijn dat je playbook faalt vanwege een ontbrekend aanhalingsteken of een tab of spatie issue! Dit wordt ook wel linting genoemd.
Linting kun je ook al inschakelen in je IDE zoals VSCode. Er zijn specifieke Ansible, Terraform etc linting extensies beschikbaar.

In een functionele test test je bijvoorbeeld de werking en output van een enkel playbook of role. Doet deze wat het zou moeten doen?
Je kunt dit bijvoorbeeld doen door het playbook te draaien en de output te bekijken. 

Integratietesten zijn bijvoorbeeld van toepassing voor Ansible bij het gebruik van rollen. Werken je playbooks nog goed wanneer je ze in grotere eenheden integreert? Denk aan het testen van rollen. Je wil dat de rollen in meerdere playbooks blijven werken en de verwachte output geven. Of heb je ergens in een playbook iets gezet wat de werking van je role ongedaan maakt o.i.d.?

Elke techniek die hieronder wordt besproken, biedt meer waarde dan de vorige, maar is ook complexer en misschien niet de extra installatie- en onderhoudslasten waard, afhankelijk van je playbook.

We beginnen met de eenvoudigste en meest basale tests en gaan dan over naar volwaardige functionele testmethoden en testautomatisering.

### Debugging en Asserting

Voor de meeste playbooks is het testen van configuratiewijzigingen en het resultaat van de uitgevoerde opdrachten het enige dat je nodig hebt. En als je tests met behulp van enkele ingebouwde hulpprogrammamodules van Ansible uitvoert tijdens het draaien van je playbook, weet je meteen zeker dat het systeem zich in de juiste staat bevindt.

Indien mogelijk moet je proberen alle eenvoudige testgevallen (bijvoorbeeld vergelijkingen en state controles) in je draaiboeken te verwerken. Ansible heeft drie modules die dit proces vereenvoudigen.

Als je een Ansible-playbook aan het ontwikkelen bent is het vaak handig om waarden van variabelen of de uitvoer van bepaalde opdrachten af te drukken tijdens de run van het playbook. Voor dit doel heeft Ansible een debug-module.

Als extreem eenvoudig voorbeeld zijn hier twee manieren waarop je debug kunt gebruiken tijdens het bouwen van een playbook:

```yaml
 1 ---
 2 - hosts: 127.0.0.1
 3   gather_facts: no
 4   connection: local
 5 
 6   tasks:
 7     - name: Register the output of the 'uptime' command.
 8       command: uptime
 9       register: system_uptime
10 
11     - name: Print the registered output of the 'uptime' command.
12       debug:
13         var: system_uptime.stdout
14 
15     - name: Print a message if a command resulted in a change.
16       debug:
17         msg: "Command resulted in a change!"
18       when: system_uptime is changed'
```

Als je dit playbook zou uitvoeren krijg je de volgende uitvoer:

```bash
$ ansible-playbook debug.yml

PLAY [127.0.0.1] ****************************************************

TASK: [Register the output of the 'uptime' command.] ****************
changed: [127.0.0.1]

TASK [Print the registered output of the 'uptime' command.] *********
ok: [127.0.0.1] => {
    "system_uptime.stdout":
      "20:55  up  7:33, 4 users, load averages: 0.95 1.36 1.43'
      '}

TASK [Print a message if a command resulted in a change.] ***********
ok: [127.0.0.1] => {
    "msg": "Command resulted in a change!"
}

PLAY RECAP **********************************************************
127.0.0.1            : ok=3    changed=1    unreachable=0    failed=0'
```

Debug-berichten zijn nuttig bij het actief debuggen van een playbook of wanneer je extra verbosity nodig hebt in de uitvoer van het playbook, maar als je een expliciete test op een bepaalde variabele moet uitvoeren, of om een of andere reden een playbook moet verlaten, biedt Ansible de fail-module, en zijn meer beknopte variant, assert.

### De fail en assert module

Zowel fail als assert zullen, wanneer ze worden geactiveerd, de run van het playbook afbreken. Het belangrijkste verschil zit in de eenvoud van hun gebruik en wat er wordt uitgevoerd tijdens een run van het playbook. Voorbeeld :

```yaml
 1 ---
 2 - hosts: 127.0.0.1
 3   gather_facts: no
 4   connection: local
 5 
 6   vars:
 7     should_fail_via_fail: true
 8     should_fail_via_assert: false
 9     should_fail_via_complex_assert: false
10 
11   tasks:
12     - name: Fail if conditions warrant a failure.
13       fail:
14         msg: "There was an epic failure."
15       when: should_fail_via_fail
16 
17     - name: Stop playbook if an assertion isn't validated.
18       assert:
19         that: "should_fail_via_assert != true"
20 
21     - name: Assertions can have contain conditions.
22       assert:
23         that:
24           - should_fail_via_fail != true
25           - should_fail_via_assert != true
26           - should_fail_via_complex_assert != true'
```

Verander in bovenstaand voorbeeld de booleans van Should_fail_via_fail, Should_fail_via_assert en Should_fail_via_complex_assert om elk van de drie fail/assert-taken te activeren, en zie welk effect het heeft.

Een fail taak wordt gerapporteerd als overgeslagen als er geen fout wordt geactiveerd, terwijl een assert-taak die slaagt, wordt weergegeven als een ok-taak met een inline-bericht in de standaarduitvoer van Ansible:

```bash
TASK [Assertions can have contain conditions.] ********************
ok: [default] => {
    "changed": false,
    "msg": "All assertions passed"
}
```

Voor de meeste testgevallen zijn debug, fails en asserts alles wat je nodig hebt om ervoor te zorgen dat je infrastructuur in de desired state verkeert tijdens een playbook run.

### YAML en Ansible linting

Als je eenmaal een playbook hebt geschreven, is het een goed idee om ervoor te zorgen dat de basis-YAML-syntaxis correct is. Veel van de meest voorkomende fouten in Ansible-playbooks, vooral voor beginners, zijn whitespace problemen, de bekende inspringende spaties.
Je kunt in je VSCode IDE een yaml lint extensie aanzetten. Daarnaast kun je op linux/macos systemen de applicatie yamllint installeren.

Stel je zou een playbook hebben met de een fout erin:

```yaml
 1 - hosts: localhost
 2   gather_facts: no
 3   connection: local
 4 
 5   tasks:
 6     - name: Register the output of the 'uptime' command.
 7       command: uptime 
 8       register: system_uptime # comment
 9 
10     - name: Print the registered output of the 'uptime' command.
11       debug:
12        var: system_uptime.stdout
```

En je laat de yamllint applicatie dit playbook nakijken, door yamllint in een directory aan te roepen, dan krijg je de volgende uitvoer:

```bash
$ yamllint .
./lint-example.yml
  1:1  warning missing document start "---"  (document-start)
  2:17 warning truthy value should be one of [false, true]  (truthy)
  7:22 error   trailing spaces  (trailing-spaces)
  8:31 warning too few spaces before comment  (comments)
  12:8 error   wrong indentation: expected 8 but found 7 (indentation)'
```

Hoewel het in eerste instantie misschien muggenzifterig lijkt, besef je na verloop van tijd hoe belangrijk het is om een specifieke stijl van coderen te gebruiken en daaraan vast te houden. Het ziet er beter uit en kan helpen voorkomen dat er fouten binnensluipen als gevolg van inspringingen, whitespaces of structurele problemen.

In dit specifieke geval kun je een aantal fouten snel herstellen:


* Voeg een yaml-documentstartindicator (---) toe bovenaan het draaiboek.
* Verwijder de extra ruimte op de opdrachtregel.
* Voeg een extra spatie toe vóór de # opmerking.
* Zorg ervoor dat de var-regel nog een spatie ingesprongen is.

Maar hoe zit het met de waarschuwing 'thruthy value'? In veel Ansible-voorbeelden wordt yes of no gebruikt in plaats van true en false. We kunnen dat toestaan door yamllint aan te passen met een configuratiebestand.

Maak een bestand in dezelfde map met de naam .yamllint, met de volgende inhoud:

```yaml
 1 ---
 2 extends: default
 3 
 4 rules:
 5   truthy:
 6     allowed-values:
 7       - 'true'
 8       - 'false'
 9       - 'yes'
10       - 'no'
```

### --syntax-check

Het controleren van de syntax door Ansible is erg eenvoudig en vereist slechts een paar seconden.

Wanneer je een playbook uitvoert met --syntax-check, worden de plays niet uitgevoerd; in plaats daarvan laadt Ansible het hele playbook statisch en zorgt ervoor dat alles kan worden geladen zonder fatale fouten. Als je een geïmporteerd taakbestand mist, een modulenaam verkeerd hebt gespeld of een module met ongeldige parameters opgeeft, zal --syntax-check het probleem snel identificeren.

Je kunt --syntax-check erg goed gebruiken als je gebruik maakt van een CI omgeving (komen we later op) of als je een pre-commit test wil doen voordat je iets in Git versiebeheer zet.

Omdat syntaxiscontrole een playbook alleen statisch laadt, kunnen dynamische includes (zoals geladen met include_tasks) en variabelen niet worden gevalideerd. Hierdoor zijn er meer integratietesten nodig om te garanderen dat een heel playbook kan draaien.


### Molecule

Tot nu toe heb je gekeken naar statische tests. Maar je kunt pas echt verifiëren dat een playbook werkt als je het daadwerkelijk uitvoert.
Het zou gevaarlijk zijn om je draaiboek tegen een productie-infrastructuur te testen, vooral als je deze aanpast of nieuwe functionaliteit toevoegt.

Molecule is een lichtgewicht, op Ansible gebaseerd hulpmiddel dat helpt bij het ontwikkelen en testen van Ansible-playbooks, rollen en collecties.

Oorspronkelijk was Molecule speciaal gebouwd voor het testen van Ansible-rollen. Molecule heeft daarom een ingebouwde functionaliteit die een rol instelt net zoals het ansible-galaxy rol init-commando dat doet, maar met een ingebouwde Molecule-configuratie.


Voer in een willekeurige map de volgende opdracht uit om een nieuwe rol te maken (waarbij myrole de naam van je role is):

```bash
ansible-galaxy role init myrole
molecule init scenario --driver-name docker
```

Als je naar de nieuwe myrole-directory gaat, zie je de standaardrollenstructuur gegenereerd door ansible-galaxy, maar met één opmerkelijke toevoeging: de molecule directory.

De aanwezigheid van deze map geeft aan dat er een of meer Molecule-scenario's beschikbaar zijn voor test- en ontwikkelingsdoeleinden. Laten we eens kijken naar wat er in het standaardscenario zit:

```bash
molecule/
  default/
    converge.yml
    molecule.yml
    verify.yml
```

Het bestand molecule.yml configureert Molecule en vertelt hoe het hele bouw- en testproces moet worden uitgevoerd.
Het converge.yml-bestand is een Ansible-playbook en Molecule voert het onmiddellijk uit in de testomgeving nadat de installatie is voltooid. Voor het testen van basisrollen bevat het Converge-playbook alleen de rol (in dit geval myrole), meer niet.

Het verify.yml-bestand is een ander Ansible-playbook, dat wordt uitgevoerd nadat Molecule het converge.yml-playbook heeft uitgevoerd en idempotence heeft getest. Het is bedoeld voor verificatietests, b.v. ervoor zorgen dat een webservice die je rol installeert correct reageert, of dat een bepaalde applicatie correct is geconfigureerd.

Ervan uitgaande dat Docker op je computer of vm is geïnstalleerd, kun je de ingebouwde tests van Molecule onmiddellijk uitvoeren op de standaardrol:

```bash
molecule test
```

De testopdracht doorloopt het volledige spectrum van de mogelijkheden van Molecule, inclusief het opzetten van een testomgeving, het uitvoeren van geconfigureerde linttools, het installeren van eventuele Ansible Galaxy-vereisten, het uitvoeren van het convergente playbook, het uitvoeren van het verificatie-playbook en het vervolgens afbreken van de testomgeving ( ongeacht of de tests wel of niet slagen).

Je kunt een subset van de taken van Molecule uitvoeren met andere opties, bijvoorbeeld:

```bash
molecule converge
```

Dit doorloopt dezelfde stappen als het testcommando, maar stopt de uitvoering nadat het converge.yml playbook is uitgevoerd en laat de testomgeving actief.
Dit is uiterst nuttig voor role ontwikkeling en debuggen.

Een typische workflow bij het ontwikkelen van een Ansible role en Molecule testing kan zijn :

* Creëer een nieuwe rol met een Molecule-testomgeving.
* Begin met het werken aan de taken in de rol.
* Voeg een fail toe: taak waarbij je een 'breakpoint' wil instellen en ```molecule converge``` draait.
* Nadat het draaiboek is uitgevoerd en de mislukte taak heeft bereikt, log je in op de omgeving met ```molecule login```.
* Verken de omgeving, controleer de configuratiebestanden, doe wat extra speurwerk als dat nodig is.
* Ga terug naar je role en werk aan de rest van de tasks van de role.
* Run molecule converge opnieuw.
* Als er problemen zijn of als je omgeving kapot gaat, voer dan ```molecule destroy```  uit om de omgeving op te ruimen en breng vervolgens ```molecule converge``` om deze weer terug te brengen.)
* Zodra je tevreden bent, voer je een ```molecule test``` uit om de volledige testcyclus te doorlopen en ervoor te zorgen dat je automatisering feilloos en met idempotentie werkt.'

Als je klaar bent met het ontwikkelen, dan kun je Molecule de omgeving laten afbreken met het commando: ```molecule destroy```

### Een playbook testen
Molecule is handig voor het testen van meer dan alleen Ansible roles. Je kunt Molecule ook gebruiken voor het testen van losse playbooks.

Stel je hebt een playbook dat een Apache-server instelt, met de volgende inhoud in main.yml:

```yaml
---
- name: Install Apache.
  hosts: all
  become: true

  vars:
    apache_package: apache2
    apache_service: apache2

  handlers:
    - name: restart apache
      ansible.builtin.service:
        name: "{{ apache_service }}"
        state: restarted

  pre_tasks:
    - name: Override Apache vars for Red Hat.
      ansible.builtin.set_fact:
        apache_package: httpd
        apache_service: httpd'
      when: ansible_os_family == 'RedHat'

  tasks:
    - name: Ensure Apache is installed.
      ansible.builtin.package:
        name: "{{ apache_package }}"
        state: present

    - name: Copy a web page.
      ansible.builtin.copy:
        content: |
          <html>
          <head><title>Hello world!</title></head>
          <body>Hello world!</body>
          </html>
        dest: "/var/www/html/index.html"
        mode: 0664
      notify: restart apache

    - name: Ensure Apache is running and starts at boot.
      ansible.builtin.service:
        name: "{{ apache_service }}"
        state: started
        enabled: true
```

Bij de linux distributies Debian en RedHat is de naam van de service/daemon voor Apache HTTPD server niet hetzelfde. In een playbook zul je dus iets met deze service naam moeten doen als je beide platformen wil ondersteunen. Een molecule test voor dit playbook zal dit dus ook aan moeten kunnen.

Voer eerst het molecule init-scenario uit om een standaard Molecule-scenario in de map van het playbook te initialiseren:

```bash
molecule init scenario
```
Omdat het hier dus om een playbook gaat en niet om een role zoals in een eerder voorbeeld moeten er een aantal wijzigingen worden aangebracht en een aantal bestanden worden verwijderd.

Open het bestand converge.yml en verwijder de bestaande ```tasks:``` sectie. Laat het Converge play de omgeving voorbereiden in de ```tasks:``` sectie en voer vervolgens het main.yml-playbook uit door het te importeren:

```yaml
 1 ---
 2 - name: Converge
 3   hosts: all
 4 
 5   tasks:
 6     - name: Update apt cache (on Debian).
 7       ansible.builtin.apt:
 8         update_cache: true
 9         cache_valid_time: 3600
10       when: ansible_os_family == 'Debian'
11 
12 - import_playbook: ../../main.yml
```

Pas het bestand molecule.yml zo aan dat het de volgende code bevat:

```yaml
1 ---
2 dependency:
3   name: galaxy
4 driver:
5   name: docker
6 platforms:
7   - name: instance
8     image: "geerlingguy/docker-debian12-ansible:latest"
9     pre_build_image: true
10    command: ""
11    volumes:
12      - /sys/fs/cgroup:/sys/fs/cgroup:rw
13    cgroupns_mode: host
14    privileged: true
15 provisioner:
16   name: ansible
17 verifier:
18   name: ansible
```

Als je nu het commando ```molecule converge``` of ```molecule test``` uitvoert vanuit de root van je playbook directory dan zal het playbook getest worden, maar ook de idempotency van het playbook. Met andere woorden: Als het playbook nogmaals wordt uitgevoerd, heeft het dan dezelfde uitkomst?

Je kunt nog een extra stap toevoegen: verificatie. Een daadwerkelijke test of een webpagina benaderbaar is. Daar gebruik je het bestand ```verify.yml``` voor. Het is een playbook waarin je doormiddel van de uri module een webpagina opvraagt.

```yaml
1 ---
2 - name: Verify
3   hosts: all
4 
5   tasks:
6   - name: Verify Apache is serving web requests.
7     ansible.builtin.uri:
8       url: http://localhost/
9       status_code: 200
```

Molecule is dus een eenvoudige maar flexibele tool die wordt gebruikt voor het testen van Ansible-rollen en playbooks. De verschillende dingen die je gedaan hebt vormen slechts een kleine subset van wat mogelijk is met Molecule.

## Gitlab CI/CD Pipeline

Nu je je code kunt testen zou het ook mooi zijn als dit automatisch zou gebeuren wanneer je nieuwe of gewijzigde code toevoegt aan het versiebeheersysteem.
Dit kun je doen door in Gitlab een CI/CD Pipeline in te richten. CI/CD staat voor Continious Integration / Continious Deployment. Bij het testen richt je je vooral op het Integration gedeelte. Het is een beetje afhankelijk van de definitie maar je zou kunnen zeggen dat het Continiuous Deployment gedeelte vooral gaat over het daadwerkelijk deployen van je infrastructuur (bv in een acceptatie of productie omgeving).

Voor deze CI/CD Pipeline heb je een zogenaamde Gitlab Runner nodig. Dit is een stukje software waarbij het het handigst is als je dit op een (aparte) VM installeert. De volgende commando's zijn voor Debian, als je een andere Linux distributie gebruikt moet je zelf de commando's opzoeken.

### Installatie gitlab runner

Voeg de officiele gitlab repository toe:

```bash
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash

```

Een eigen package genaamd gitlab-ci-multi-runner is beschikbaar in Debian Stretch. Als je gitlab-runner installeert, zal dat pakket uit de officiële repositories standaard een hogere prioriteit hebben. Het is aan te raden het package van gitlab zelf te gebruiken, daarvoor moet je wel de bron van het package handmatig instellen. De beste manier is om apt-pinning te gebruiken door een pinconfiguratiebestand toe te voegen.
Als je dit doet, zal de volgende update van het GitLab Runner-pakket - of dit nu handmatig of automatisch wordt gedaan - worden uitgevoerd met behulp van dezelfde bron:

```bash
cat <<EOF | sudo tee /etc/apt/preferences.d/pin-gitlab-runner.pref
Explanation: Prefer GitLab provided packages over the Debian native ones
Package: gitlab-runner
Pin: origin packages.gitlab.com
Pin-Priority: 1001
EOF
```

Installeer daarna het gitlab-runner package:

```bash
sudo apt-get install gitlab-runner
```

Voer nu de handelingen zoals in onderstaande screen recording uit : 

![GitLab CICD](gitlabcicd.gif)

Het commando wat je daar te zien krijgt voer je uit op je op je gitlab runner systeem.
Wanneer het registreren gelukt is heeft de runner zich bekend gemaakt als Runner op de GitLab omgeving.

Laatste stap is het toevoegen van een CI/CD workflow bestand aan je code. Voeg hiervoor een bestand ```.gitlab-ci.yml``` toe aan je code.
Een voorbeeld van code die in dit workflow bestand komt ziet er als volgt uit (Let op, dit is maar een voorbeeld, dit is niet zomaar toepasbaar. Het kan zomaar zijn dat je in jouw project geen docker gebruikt. Hou hier dus ook rekening mee bij het aanmaken van de runner) :

```yaml
stages:
  - deploy

image:
  name: registry.gitlab.com/torese/docker-ansible

variables:
    ANSIBLE_HOST_KEY_CHECKING: 'false'
    ANSIBLE_FORCE_COLOR: 'true'
    ANSIBLE_PYTHON_INTERPERTER: /usr/bin/python3

before_script:
  - apt install -y python3
  - ansible --version

run:
  stage: deploy
  tags:
    - ansible
    - username
  script:
    - ansible-playbook main.yml
```

Om het stap voor stap te doorlopen, in onderstaande regel definieer je een naam voor een stage:
```yaml
stages:
  - deploy
```

Deze build pipeline gebruikt het standaard docker ansible image:
```yaml
image:
  name: registry.gitlab.com/torese/docker-ansible
```

In de variabelen sectie kun je een aantal variabelen opgeven die je bijvoorbeeld anders in een Ansible inventory zou plaatsen:
```yaml
variables:
    ANSIBLE_HOST_KEY_CHECKING: 'false'
    ANSIBLE_FORCE_COLOR: 'true'
    ANSIBLE_PYTHON_INTERPERTER: /usr/bin/python3
```

Het ```before script``` gedeelte geeft aan welke taken moeten worden uitgevoerd voordat het playbook zal worden aangeroepen:

```yaml
before_script:
  - apt install -y python3
  - ansible --version
```

En als laatste de eigenlijke taak van deze build pipeline, het draaien van het ansible playbook. Hier kun je ook tags opgeven die je bij het maken van je runner hebt opgegeven.
```yaml
run:
  stage: deploy
  tags:
    - ansible
    - username
  script:
    - ansible-playbook main.yml
```

Dit is slechts 1 voorbeeld van een Gitlab workflow bestand. Er zijn vele verschillende configuraties mogelijk voor bijvoorbeeld Terraform, Molecule e.d. De basis met een runner en een ```.gitlab-ci.yml``` bestand blijft hetzelfde.

Commit en Push de aangepaste code naar Gitlab en bekijk in het Pipeline overzicht of de build/test geslaagd is.

> Opdrachten:
> - Maak een playbook waarbij het pakket ```apache2``` wordt geinstaleerd en er een melding wordt gegeven als dit gelukt is.

> - Installeer molecule (pip install molecule en pip install molecule[docker]) en yamllint en docker (sudo apt install yamllint en sudo apt install docker)
> - Maak een Ansible playbook met bijbehorende molecule test voor de installatie van Solr
> - Maak Ansible roles met bijbehorende molecule test waarbij Nginx, Grafana en Prometheus geinstalleerd worden. Gebruik bijgeleverde nginx.conf configuratie.

> - Richt een Gitlab Runner in en voeg deze toe aan je Gitlab project
> - Maak een playbook wat een package (bv apache of nginx) installeert en maak hier een CI/CD configuratie voor. Zorg dat het playbook automatisch draait bij push van jouw code.
> - (Optioneel) Maak een terraform bestand waarbij je een simpele vm deployed en maak hier een CI/CD configuratie voor. Zorg dat het bestand automatisch draait bij push van jouw code.
