1. Voeg een extra harde schijf toe aan je VM in skylab van bv 25GB.

Voer de volgende commando's uit op de VM:

2. ```fdisk /dev/sdb > n (new )> p (primary partition) > volg hierna de default waardeni```

3. ```pvcreate /dev/sdb1```

4. ```vgextend ubuntu-vg /dev/sdb1```

5. ```lvextend -l100%FREE /dev/ubuntu-vg/ubuntu-lv```

6. ```resize2fs /dev/ubuntu-vg/ubuntu-lv```
