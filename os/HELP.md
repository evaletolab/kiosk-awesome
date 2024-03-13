## BIOS 
- desactiver le secureboot
- changer le boot order pour l'USB
- changer l'heure
- activer l'allumage à 7h00
- F9 boot menu
- F10 bios setup


## update content

to set permissions, run:

```
$ sudo ~chmod a+w /media/USER_NAME/DEVICE_ID
```

to upload media content, run: 

```
$ rsync -av --ignore-times --checksum  dist/* /media/USER_NAME/DEVICE_ID
```
