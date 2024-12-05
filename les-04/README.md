# Les 4 - Hello, Ansible (2)!

Datum: 

Leerdoelen:

1. Aan het einde van deze les weet je wat Ansible Handlers en Variabelen zijn en hoe je ze in kunt zetten.
2. Aan het einde van deze les weet je hoe je een playbook kunt include of importeren en wat het verschil is tussen beiden.
3. Aan het einde van deze les kun je een Ansible role maken en toepassen in een playbook.

Inhoud:

  - Handlers
  - Variabelen
  - If/when/then
  - Roles, includes en imports
  - Opdracht 3 en 4 tijd

Vereisten:
In de vorige les heb je een Ansible playbook gemaakt. Dit playbook heb je nodig in deze les.
De Ansible playbooks en de eenvoudige organisatie van de draaiboeken die we daar hebben gebruikt en gemaakt, omvatten veel voorkomende gebruiksscenario's. In deze les gaan we wat dieper in op technieken die je in deze playbooks kunt gebruiken of hoe je je playbook zou kunnen verkorten of generiek zou kunnen maken.

## Handlers

Stel je hebt net (in je playbook natuurlijk) een wijziging gedaan aan het configuratiebestand van je webserver. De webserver zal dan deze configuratie opnieuw moeten inlezen. Normaal gesproken doe je dat met een reload of restart. Je kunt dit commando direct achter de wijziging zetten in je Ansible playbook als losse taak.

Als je dit meerdere keren moet doen is dat niet een erg efficiente manier van werken. Daarnaast kun je de code in je playbook ook verkorten door een handlers te gaan gebruiken.
Handlers definieer je op een aparte plaats in je playbook en roep je aan in je andere taken doormiddel van de 'notify' optie in een taak.
Ze worden apart gedefinieerd onder de sectie handlers: in het playbook en krijgen een naam. Hier is een voorbeeld van hoe een handler kan worden gedefinieerd:

```yaml
---
handlers:
  - name: restart apache
    service:
      name: apache2
      state: restarted
```
In dit voorbeeld wordt een handler met de naam "restart apache" gedefinieerd die de Apache-webserver herstart als deze wordt geactiveerd.


Handlers worden niet automatisch uitgevoerd wanneer ze worden gedefinieerd. In plaats daarvan worden ze geactiveerd door een andere taak met behulp van de module notify: in de taakdefinitie. Hier is een voorbeeld van hoe een taak een handler kan activeren:

```yaml
---
tasks:
  - name: Update Apache configuration
    template:
      src: templates/httpd.conf.j2
      dest: /etc/httpd/conf/httpd.conf
    notify: restart apache
```

In dit voorbeeld wordt de handler "restart apache" geactiveerd nadat de taak "Update Apache configuration" is voltooid.

Het zou ook voor kunnen komen dat je meerdere handlers wil activeren na het uitvoeren van een taak.
De code ziet er dan als volgt uit :

```yaml
  - name: Update Apache configuration
    template:
      src: templates/httpd.conf.j2
      dest: /etc/httpd/conf/httpd.conf
    notify: 
      - restart apache
      - restart memcached
```

Wanneer je met handlers werkt moet je een aantal dingen onthouden:
- Handlers worden alleen uitgevoerd als de taak waarin ze aangeroepen worden succesvol is uitgevoerd. Als een taak wordt geskipped of faalt zal de handler niet aangeroepen worden.
- Handlers zullen maar 1x uitgevoerd worden, aan het einde van een play. Als het echt noodzakelijk is dat de handler eerder (bv middenin een playbook) worden uitgevoerd, kun je de flush_handlers module gebruiken

Om te oefenen met handlers kun je nu opdracht 1 uitvoeren : Maak een playbook waarin je Nginx installeert, en maak gebruik van een handler om nginx na installatie te herstarten

> Opdracht: Maak een playbook waarin je Nginx installeert, en maak gebruik van een handler om nginx na installatie te herstarten

## Variabelen

Variabelen in Ansible werken net als variabelen in de meeste andere systemen of talen. Variabelen beginnen meestal met een letter ([A-Za-z]), maar kunnen ook beginnen met een underscore (_).
Variabelen kunnen een willekeurig aantal letters, underscores of cijfers bevatten.

Geldige namen zijn bijvoorbeeld foo, foo_bar, foo_bar_5, _foo en fooBar, hoewel de standaard is om alle kleine letters te gebruiken en doorgaans cijfers in variabelennamen te vermijden.

Ongeldige namen van variabelen zijn foo-bar, 12, foo.bar en foo bar.

In een inventory bestand in ini stijl wordt de waarde van een variabele toegewezen met behulp van een is gelijk (=) teken, als volgt:

```
foo=bar
```

In een playbook of een variabelen include bestand wordt de waarde van een variabele toegewezen met behulp van een dubbele punt, zoals :

```yaml
foo: bar
```

### Playbook variabelen

Er zijn veel verschillende manieren waarop je variabelen kunt definieren voor gebuik in taken.
Variabelen kunnen worden doorgegeven via de command line, bij het aanroepen van het ansible playbook commando, met de optie --extra-vars:

```bash
ansible playbook voorbeeld.yml --extra-vars "foo=bar"
```

Je kunt op deze manier ook extra variabelen doorgeven met behulp van een JSON of YAML bestand.
```bash
ansible playbook voorbeeld.yml --extra-vars @meer_variabelen.yaml
```

Maar het is dan beter gebruik om de variabelen in een vars sectie in het playbook op te nemen:

```yaml
---
- hosts: example

  vars:
    foo: bar
  
  tasks:
    - debug:
        msg: "Variabele 'foo' heeft de waarde {{ foo }}"
```

De taak 'debug' heb je misschien nog niet eerder gezien, maar hiermee kun je informatie op het scherm van het uitvoerende systeem terecht laten komen.

In een playbook kun je ook variabelen die je in een los bestand hebt gezet laten inladen:
(vars.yaml staat hierbij in dezelfde directory als je playbook)
```yaml
---
- hosts: example

  vars_files:
    - vars.yaml
  
  tasks:
    - debug:
        msg: "Variabele 'foo' heeft de waarde {{ foo }}"
```

### Inventory Variabelen

Variabelen kunnen ook toegevoegd worden vanuit een inventory bestand, inline in de host/groep definitie of na de groep definitie:

```ini
# Host-specifieke definitie
[servers]
server1.example.com proxy_state=absent
server2.example.com proxy_state=present

# Variabelen voor de hele groep
[servers:vars]
cdn_host=content.static.example.com
api_version=4.0.2
```
### Registered Variabelen
Het komt vaak voor dat je een opdracht wil uitvoeren en vervolgens de return code ervan wil gebruiken om te bepalen of je een andere taak wil uitvoeren.
Voor deze situaties kun je Ansible register gebruiken om de uitvoer van een bepaalde opdracht tijdens runtime in een variabele op te slaan.

```yaml
---
- hosts: localhost
  tasks:
    - name: Run a command an register the output
      command: echo "Hello, World!"
      register: command_output

    - name: Display the registered output
      debug:
        var: command_output.stdout

    - name: Perform another task using the registered output
      debug:
        msg: "The registered output was: {{ command_output.stdout }}"
```

### Variabelen gebruiken

Variabelen (verzameld door Ansible, gedefinieerd in een inventory, playbook of een variabele bestand) kunnen worden gebruikt als onderdeel van een taak door de syntax {{ variabele }} te gebruiken. Bijvoorbeeld:

```yaml
- command: "/opt/my-app/rebuild {{ environment }}"
```

Wanneer deze taak uitgevoerd wordt zal Ansible de waarde van variabele {{ environment }} hierin zetten. Zodat het commando wat uitgevoerd wordt bijvoorbeeld /opt/my-app/rebuild dev is.

Door Ansible verzamelde informatie over een systeem (bv Via gather_facts of een debug taak in een playbook) zijn veelal arrays met allerlei informatie.
Als je bijvoorbeeld de informatie van een netwerkinterface wil weten kun je de volgende taak gebruiken:

```yaml
tasks:
  - debug
      var: ansible_eth0
# Waarbij eth0 de netwerkinterface is.
```

Dit zal resulteren in een array met allerlei informatie. Door gebruik te maken van een . of [] kunnen we inzoomen op specifieke informatie

```yaml
tasks:
  - debug
      msg: {{ ansible_eth0.ipv4.address }}

  - debug
      msg: {{ ansible_eth0['ipv4']['address']}}
```

### Host en Group variabelen
Met Ansible kun je gemakkelijk variabelen per host of per groep definieren of overschrijven. Zoals eerder aangegeven kan dit in je inventory bestand:

```ini
[groep1]
host1 admin_user=student1
host2 admin_user=student2
host3
host4

[groep1:vars]
admin_user=docent
```

In dit geval krijgt elke host in groep1 docent als admin user, behalve host1 en host2, deze krijgen een student als admin_user.

Dit is handig en werkt goed als je een of twee variabelen per host of per groep moet definieren, maar zodra je je met meer playbooks gaat bezighouden moet je misschien meerdere hostspecifieke variabelen toevoegen en wordt het onoverzichtelijk. In deze situaties kun je de variabelen op een andere plek definieren om het onderhoud en de leesbaarheid veel gemakkelijker te maken.

Ansible zoekt in dezelfde map als je inventory bestand naar twee specifieke mappen: group_vars en host_vars.

Je kunt Yaml bestanden in deze mappen plaatsen, genoemd naar de groepsnaam of hostnaam die is gedefinieerd in je inventory bestand. Als we het voorbeeld hierboven gebruiken zal dit er als volgt uit zien:

```ini
#/home/student/code/ansibleproject/group_vars/groep1
admin_user=docent
```

```ini
#/home/student/code/ansibleproject/host_vars/host1
admin_user=student1
```

```ini
#/home/student/code/ansibleproject/host_vars/host2
admin_user=student2
```

Zelfs als je een inventory bestand vanuit een andere locatie gebruikt zal Ansible ook host- en groepsvariabelebestanden gebruiken die zich in de mappen group_vars en host_vars van je playbook bevinden. Dit is handig als je een volledige playbook- en infrastructuurconfiguratie wil samenbrengen in bv een versiebeheersysteem

### Facts
Wanneer je een Ansible-playbook uitvoert, verzamelt Ansible standaard eerst informatie (feiten/facts) over elke host in het stuk. Misschien heb je het volgende al eens langs zien komen bij het uitvoeren van een playbook :

```bash
$ ansible-playbook playbook.yml

PLAY [group]
***********************************************************

GATHERING FACTS
***********************************************************
ok: [host1]
ok: [host2]
ok: [host3]
```

Facts kunnen erg nuttig zijn als je playbooks gebruikt. Je kunt de verzamelde informatie zoals IP-adressen, CPU type, schijfruimte, OS type en netwerkinterface informatie gebruiken om te veranderen wanneer bepaalde taken worden uitgevoerd, of om bepaalde informatie te wijzigen die in configuratiebestanden wordt gebruikt. Bijvoorbeeld het aantal gelijktijdige processen bij 8/16 of 32 GB geheugen.

Als je deze feiten niet nodig hebt in je playbook (en je een paar seconden voor het uitvoeren van je playbook wil besparen) gebruik je de volgende regel in je playbook:

```
---
- hosts: all
  gather_facts: no <--
```

## If/Then/When
Veel taken in een playbook hoeven vaak alleen onder bepaalde omstandigheden te worden uitgevoerd.

### when
Een van de handigste opties die je toe kan voegen aan een play is het when statement. Bijvoorbeeld:

```
- apt: name=mysql-server state=present
  when: is_db_server
```

Dit voorbeeld gaat er vanuit dat de variabele is_db_server ergens op true of false gezet wordt eerder in het playbook (met bv register).
Als de waarde true is zal het mysql-server geinstalleerd worden door de module apt, als deze false is zal de taak over worden geslagen.

Er zijn allerlei mogelijkheden:

```yaml
# Voer ping_hosts shell script uit als ping_hosts true is:
- command: /usr/local/bin/ping-hosts.sh
  when: ping_hosts

# Voer het script git cleanup uit als er een development branch is en het een app_server is
- command: chdir=/path/to/project git branch
  register: git_branches
- command: /path/to/project/scripts/git-cleanup.sh
  when: "(is_app_server == true) and ('development' in git_branches.stdout)"

# Downgrade PHP versie als de huidige versie 7.0 bevat
- shell: php --version
  register: php_version
- shell: yum -y downgrade php*
  when: "'7.0' in php_version.stdout"

# Kopieer een bestand naar de remote_server als het hosts bestand niet bestaat
- stat: path=/etc/hosts
  register: hosts_file
- copy: src=path/to/local/file dest=/path/to/remote/file
  when: hosts_file.stat.exists == false
```

### changed_when en failed_when
Soms is het voor Ansible moeilijk om te bepalen wanneer een commando tot wijzigingen leidt, bij de shell en command module zal Ansible bijvoorbeeld altijd een 'changed' weergeven. De meeste Ansible modules rapporteren of ze correct tot wijzigingen hebben geleid, maar bij shell en command modules is het dus verstandig iets extra's te gebruiken. Dit kan met changed_when en failed_when.

Bijvoorbeeld
```yaml
- name: Run script
  command: "/usr/local/bin/check_install_script.sh"
  register: script_output
  changed_when: "'Installed' in script_output.stdout"
```

Hierbij wordt er een variabele script_output met register gevuld en wordt aan Ansible verteld dat er iets gewijzigd is als 'Installed' in deze output staat.

## Roles, includes en imports

Tot nu toe heb je vrij eenvoudige voorbeelden gezien en gebruikt. De meeste voorbeelden voor een bepaalde server met een aantal taken.
Wanneer je veel taken in een playbook wil gaan stoppen is 1 playbook vaak niet het meest handige om te organiseren en te onderhouden.

Ansible is flexibel in het organiseren van taken. Er zijn meerdere manieren om taken op te knippen en delen herbruikbaar te maken.

### Import
Bij de variabelen heb je al gezien dat het mogelijk is om bestanden op te nemen in je playbook door het gebruik van vars_files. Daar werder variabelen in een apart bestand geplaatst en ingelezen bij het uitvoeren van het playbook in plaats van ze direct op te nemen in het playbook.
Op een vergelijkbare manier kunnen taken eenvoudig worden opgenomen. In de tasks: sectie van het playbook kun je met import_tasks iets soortgelijks doen.

```yaml
tasks:
  - import_tasks: imported_tasks.yml
```

Het imported_tasks.yml bestand ziet er bijvoorbeeld als volgt uit:

```yaml
# user.yml
---
- name: Add profile info for user.
  copy:
    src: example_profile
    dest: "/home/{{ username }}/.profile"
    owner: "{{ username }}"
    group: "{{ username }}"
    mode: 0744

- name: Restart example service
  service:
    name: example
    state: restarted
```

Valt het je op dat dit bestand niet begint met '- hosts: '? In een bestand wat je importeert hoef je dit niet toe te voegen.
En het playbook waarin bovenstaande playbook wordt geimporteerd?

```yaml
---
- hosts: all

  tasks:
    - import tasks: user.yml
      vars:
        username: student

    - import_tasks: user.yml
      vars:
        username: docent
```

### Includes

Als je import_tasks gebruikt, importeert Ansible het tasks bestand een keer statisch alsof het deel uitmaakt van het hoofdplaybook voordat het Ansible playbook wordt uitgevoerd.

Als je taken wil opnemen die dynamisch zijn (bijvoorbeeld alleen uitvoeren als het OS Redhat is, of als een bepaalde directory bestaat) dan kun je include_tasks gebruiken.

Bijvoorbeeld:

```yaml
---
- name: Check if extra_tasks is present.
  stat:
    path: tasks/extra-tasks.yml
  register: extra_tasks_file
  connection: local

- include_tasks: tasks/extra-tasks.yml
  when: extra_tasks_file.stat.exists
```

In dit voorbeeld wordt op het lokale systeem gekeken of extra-tasks.yml bestaat, zo ja dan wordt het uitgevoerd.

Of een voorbeeld als het remote OS debian is
```yaml
- name: Include tasks for Debian
  include_tasks: debian_tasks.yml
  when: "'Debian' in ansible_facts['ansible_distribution']"
```

### Roles

Het opnemen van playbooks in playbooks door het importeren of includen maakt je playbook organisatie leesbaarder en beter te onderhouden, maar zodra je begint met het maken van echt complexe infrastructuur zou het alsnog een onoverzichtelijke brei van in elkaar grijpende playbooks kunnen worden.

Ansible Roles kunnen hierbij helpen. Dit zijn een soort packages met eigen playbooks met daarin taken, handlers, variabelen e.d.
Deze roles zijn hierdoor herbruikbaar binnen meerdere projecten.

Een role bestaat standaard uit twee directories, meta en tasks.

```
role_name/
  meta/
  tasks/
```

Als je een directorystructuur maakt zoals hierboven weergegeven, met een bestand main.yml in
elke map, zal Ansible alle taken uitvoeren die zijn gedefinieerd in tasks/main.yml als je de role aanroept vanuit je playbook.
Een role aanroepen binnen een playbook doe je op de volgende manier:

```yaml
---
- hosts: all
  roles:
    - role_name
```

Het is gangbaar om roles binnen je project te plaatsen in de directory 'roles'. Maar het kan ook in een default role directory op je systeem (bijvoorbeeld handig als je op 1 systeem meerdere projecten hebt staan.) Die default directory pas je aan in '/etc/ansible/ansible.cfg'.

#### Een role bouwen
Laten we een simpele role bouwen, eentje waarin een nodejs server wordt opgezet.
We hebben een project met het volgende playbook :

```yaml
---
- hosts: all

  vars:
    node_apps_location: /usr/local/opt/node

  tasks:
    - name: Install NodeJS
      apt:
        name: nodejs
        state: present
        
    - name: Install NPM
      apt:
        name: npm
        state: present

    - name: Install Forever
      apt:
        name: forever
        state: present

    - name: Ensure Node.js app folder exists.
      file: "path={{ node_apps_location }} state=directory"

    - name: Copy example Node.js app to server.
      copy: "src=app dest={{ node_apps_location }}"

    - name: Install app dependencies defined in package.json.
      npm: "path={{ node_apps_location }}/app"

    - name: Check list of running Node.js apps.
      command: /usr/local/bin/forever list
      register: forever_list
      changed_when: false

    - name: Start example Node.js app.
      command: "/usr/local/bin/forever start {{ node_apps_location }}/app/app.js"
      when: "forever_list.stdout.find(node_apps_location + '/app/app.js') == -1"
```

Het generieke deel uit dit project is de installatie van NodeJS, NPM en Forever. Dit kunnen we in een role stoppen.
Dus in het project maken we een roles directory met daarin een meta en tasks directory.
In de meta folder voeg je een bestand main.yml toe met de volgende inhoud:

```yaml
---
dependencies: []
```
Dit wil zeggen dat onze rol geen afhankelijkheden met andere roles heeft.

In de tasks directory maak je ook een bestand main.yml met de taken die generiek zijn, dus :

```yaml
---
- name: Install NodeJS
  apt:
    name: nodejs
    state: present
    
- name: Install NPM
  apt:
    name: npm
    state: present

- name: Install Forever
  npm:
    name: forever
    global: yes
    state: present
```

Je project directory structuur zou er nu als volgt uit moeten zien :

```bash
nodejs-app/
  app/
    app.js
    package.json
  playbook.yml
  roles
    nodejs
      meta/
        main.yml
      tasks/
        main.yml
```

Het playbook kan nu aangepast worden door de taken voor de installatie van NodeJS weg te halen en de role toe te voegen:

```yaml
---
- hosts: all

  vars:
    node_apps_location: /usr/local/opt/node

  roles:
    - nodejs

  tasks:
    - name: Ensure Node.js app folder exists.
      file: "path={{ node_apps_location }} state=directory"

    - name: Copy example Node.js app to server.
      copy: "src=app dest={{ node_apps_location }}"

    - name: Install app dependencies defined in package.json.
      npm: "path={{ node_apps_location }}/app"

    - name: Check list of running Node.js apps.
      command: /usr/local/bin/forever list
      register: forever_list
      changed_when: false

    - name: Start example Node.js app.
      command: "/usr/local/bin/forever start {{ node_apps_location }}/app/app.js"
      when: "forever_list.stdout.find(node_apps_location + '/app/app.js') == -1"
```

De installatie van nodejs is nu een generiek pakket geworden, de specifieke configuratie van het systeem staat alleen nog maar uitgewerkt onder de taken.

Maak nu opdracht 2: Maak een role en playbook waarin je NodeJS installeert en installeer het nodejs package jslint.

Een Ansible role kan ook nog de directories 'defaults' en 'vars' (met elk een eigen main.yml bestand) bevatten. In vars/main.yml kan variabele informatie opgeslagen worden en in 'defaults/main.yml' een default waarde lijst.

Bijvoorbeeld de waarde van een variabele met te installeren NodeJS packages (zoals forever in de role hierboven.)

```yaml
node_npm_modules
  - forever
```

In de role kun je dan verwijzen naar deze default waarde

```yaml
- name: Install npm modules required by our app.
  npm: name={{ item }} global=yes state=present
  with_items: "{{ node_npm_modules }}"
```

Maar we kunnen deze default ook overschrijven in onze variabelen lijst in het playbook. Hierdoor kun je een generieke role gebruiken, maar per project of playbook een andere lijst aan NodeJS packages laten installeren.

```yaml
---
- hosts: all

  vars:
    node_npm_modules:
      - forever
      - async
      - request

  roles:
    - nodejs

    ..
```

Je kunt ook meerdere roles opnemen in een playbook, bijvoorbeeld:

```yaml
---
- hosts: all
  roles:
    - ubuntu-setup
    - firewall
    - nodejs
    - app-deploy
```

> Opdracht: 
> - Zoek uit wat NodeJS is. Maak een playbook met daarin een role waarin je NodeJS installeert en installeer via het playbook het nodejs package jslint.

#### Andere role onderdelen

##### Handlers

In een van de eerdere voorbeelden heb je naar handlers gekeken: taken die via de 'notify' optie kunnen worden aangeroepen.

```yaml
handlers:
  - name: restart apache
    service: name=httpd state=restarted
```

Roles kunnen ook eigen handlers bevatten. Deze hoef je dan niet meer op te nemen in je playbook. In een role zit een aparte directory handlers met daarin ook weer een main.yml bestand. In dit 'handlers/main.yml' bestand beschrijf je de handlers. In het bovenstaande voorbeeld zou dit bestand er als volgt uit zien:

```yaml
---
- name: restart apache
  service: name=httpd state=restarted
```

Handlers worden in deze constructie op dezelfde manier aangeroepen, dus door 'notify: restart apache'.

##### Files en Templates
Soms kun je binnen een Ansible role ook een bestand of een template bestand (bv een configuratie file) nodig hebben. Deze kun je ook opnemen in je role door er een directory voor aan te maken.
Laten we voor de volgende voorbeelden aannemen dat onze rol is gestructureerd met files en
templates in respectievelijk files- en templatedirectories:

```bash
roles/
  example/
    files/
      example.conf
    meta/
      main.yml
    templates/
      example.xml.j2
    tasks/
      main.yml
```

De copy functie in de role weet dat een bestand vanuit de files directory zal moeten worden gekopieerd.

```yaml
- name: Copy configuration file to server
  copy:
    src: example.conf
    dest: /etc/myapp/example.conf
    mode: 0644
```

En idem voor de templates functie:

```yaml
- name: Copy configuration file to server using a template
  template:
    src: example.xml.j2
    dest: /etc/myapp/example.xml
    mode: 0644
```

Als laatste nog een voorbeeld hoe krachtig roles kunnen zijn, een complete LAMP server (Linux, Apache, Mysql en PHP) in 9 regels Ansible code:

```yaml
---
- hosts: all
  become: true

  roles:
    - mysql
    - apache
    - php
    - php-mysql
```
> Opdracht : 
> - Deploy 2 vm's. Zorg ervoor dat de IP's en hostnamen in een inventory komen. Maak Ansible roles die apache, php en php-mysql op vm 1 installeren en mysql op vm 2. In je inventory moet duidelijk zijn dat het om een webserver en een database server gaat.
> - Zoek uit wat Ansible Galaxy is en upload je zojuist aangemaakte roles hier naar toe. (Hint, kopieer je code naar een GitHub repo en laat hier de role van bouwen) Voeg een playbook toe wat deze role gebruikt.