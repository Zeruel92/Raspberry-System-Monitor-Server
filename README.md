# Raspberry System Monitor Server

Server che fornisce le API per l'app [Raspberry System Monitor][1].
Al momento il server fornisce l'API per:

- [x] Uptime
- [x] Controllo remoto torrent
- [x] Controllo remoto [teledart][2]
- [x] Controllo remoto Condivisioni Samba (avvia ferma daemon)
- [x] Controllo remoto server ssh
- [x] Controllo remoto server netatalk (condivisioni Apple APFS)


# Installing service
Per gli utenti Systemd è sufficiente copiare il file rsms.service in /lib/systemd/sytem e dare un 
```bash
sudo systemctl daemon-reload
```
 e poi avviare il server con 

```bash
sudo systemctl start rsms
```

[//]: #'links'
[1]: https://github.com/pspgt/Raspberry-System-Monitor
[2]: https://github.com/pspgt/teledart
