# TP2 : Utilisation courante de Docker

## TP2 Commun : Stack PHP

🌞 docker-compose.yml

[le docker-compose](./tp2/docker-compose.yml)

## TP2 admins : PHP stack

### I. Good practices

🌞 Limiter l'accès aux ressources

```bash
farkas@COIN-COIN:~$ docker run -m="1g" --cpus="1.0" -d phpmyadmin
farkas@COIN-COIN:~$ docker ps
CONTAINER ID   IMAGE        COMMAND                  CREATED         STATUS         PORTS     NAMES
7d43a0e4285d   phpmyadmin   "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   80/tcp    gracious_ride
farkas@COIN-COIN:~$ docker stats
CONTAINER ID   NAME            CPU %     MEM USAGE / LIMIT   MEM %     NET I/O       BLOCK I/O     PIDS
7d43a0e4285d   gracious_ride   0.00%     12.11MiB / 1GiB     1.18%     3.26kB / 0B   0B / 8.19kB   6
```

🌞 No root

```bash
sudo useradd dock_python -s /bin/sh -u 2011
sudo usermod -aG dock_python docker
docker run -it --user 1000 python
farkas@COIN-COIN:~$ ps -ef | grep docker
root        1099       1  0 22:45 ?        00:00:00 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
dock_python 6799    3445  0 22:52 pts/3    00:00:00 docker run -it --user 2011 python
farkas      6897    6883  0 22:53 pts/4    00:00:00 grep --color=auto docker
```

### II. Reverse proxy buddy

#### A. Simple HTTP setup

🌞 Adaptez le docker-compose.yml 

[le docker-compose j'ai garde le meme pour tous le tp](./tp2/docker-compose.yml)
[la conf du nginx](./tp2/nginx/default.conf)

```bash
farkas@COIN-COIN:~$ docker ps
CONTAINER ID   IMAGE        COMMAND                  CREATED              STATUS          PORTS                                                                      NAMES
9d3acf5ce0fe   nginx        "/docker-entrypoint.…"   About a minute ago   Up 58 seconds   0.0.0.0:80->80/tcp, :::80->80/tcp, 0.0.0.0:443->443/tcp, :::443->443/tcp   tp2-nginx-1
581eb3328735   phpmyadmin   "/docker-entrypoint.…"   About a minute ago   Up 59 seconds   80/tcp                                                                     tp2-phpmyadmin-1
4714bd16a1d5   tp2-phpute   "docker-php-entrypoi…"   About a minute ago   Up 59 seconds   80/tcp                                                                     tp2-phpute-1
c0a0bc98dd68   mysql        "docker-entrypoint.s…"   About a minute ago   Up 59 seconds   3306/tcp, 33060/tcp

farkas@COIN-COIN:~$ curl localhost:8081
curl: (7) Failed to connect to localhost port 8081 after 0 ms: Couldn t connect to server
farkas@COIN-COIN:~$ curl pma.supersite.com |head -n 10 && curl pma.supersite.com |tail -n 5
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 51778    0 51778    0     0  1433k  <!doctype html>--:--:-- --:--:--     0
 <html lang="en" dir="ltr">
 <head>
   <meta charset="utf-8">
 0  <meta name="viewport" content="width=device-width, initial-scale=1">
 -  <meta name="referrer" content="no-referrer">
-:  <meta name="robots" content="noindex,nofollow,notranslate">
--  <meta name="google" content="notranslate">
:  <style id="cfs-style">html{display: none;}</style>
-  <link rel="icon" href="favicon.ico" type="image/x-icon">
100 51778    0 51778    0     0  1421k      0 --:--:-- --:--:-- --:--:-- 1404k
curl: (23) Failure writing output to destination
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  136k    0  136k    0     0  5604k      0 --:--:-- --:--:-- --:--:-- 5675k

  
  
  </body>
</html>

farkas@COIN-COIN:~$ curl www.supersite.com
<h1>FEUR</h1>
farkas@COIN-COIN:~$ sudo cat /etc/hosts |head -n 4
127.0.0.1	localhost
127.0.1.1	COIN-COIN
127.0.0.1 www.supersite.com
127.0.0.1 pma.supersite.com
```

#### B. HTTPS auto-signé

🌞 HTTPS auto-signé

bon c'est toujours les memes mais comparé a quand j'ai commence a les ecrire ils sont bien shiny mtn  
[le docker-compose j'ai garde le meme pour tous le tp](./tp2/docker-compose.yml)  
[la conf du nginx](./tp2/nginx/default.conf)

```bash
farkas@COIN-COIN:~/git/docker/tp2/key$ ls
'*'   pma.supersite.com.crt   pma.supersite.com.key   www.supersite.com.crt   www.supersite.com.key
farkas@COIN-COIN:~$ curl http://www.supersite.com
<html>
<head><title>301 Moved Permanently</title></head>
<body>
<center><h1>301 Moved Permanently</h1></center>
<hr><center>nginx/1.25.3</center>
</body>
</html>
farkas@COIN-COIN:~$ curl https://www.supersite.com
curl: (60) SSL certificate problem: self-signed certificate
More details here: https://curl.se/docs/sslcerts.html
curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
farkas@COIN-COIN:~$ curl -k  https://www.supersite.com
<h1>FEUR</h1>
```

#### C. HTTPS avec une CA maison

🌞 Générer une clé et un certificat de CA

```bash
farkas@COIN-COIN:~/git/docker/tp2/cert$ ls
CA.key  CA.pem
```

🌞 Générer une clé et une demande de signature de certificat pour notre serveur web

```bash
farkas@COIN-COIN:~/git/docker/tp2/cert$ ls
CA.key  CA.pem  pma.supersite.com.csr  pma.supersite.com.key  www.supersite.com.csr  www.supersite.com.key
```

🌞 Faire signer notre certificat par la clé de la CA

```bash
farkas@COIN-COIN:~/git/docker/tp2/cert$ ls |grep crt
pma.supersite.com.crt
www.supersite.com.crt
```

🌞 Ajustez la configuration NGINX

j'ai juste changer le chemin de /key a /cert

[la conf nginx](./tp2/nginx/default.conf)

🌞 Prouvez avec un curl que vous accédez au site web

```bash
farkas@COIN-COIN:~/git/docker/tp2/cert$ curl -k https://www.supersite.com
<h1>FEUR</h1>
```

🌞 Ajouter le certificat de la CA dans votre navigateur

```bash
farkas@COIN-COIN:~/git/docker/tp2/cert$ cat www.supersite.com.crt www.supersite.com.key > www.supersite.com.pem
farkas@COIN-COIN:~/git/docker/tp2/cert$ cat pma.supersite.com.crt pma.supersite.com.key > pma.supersite.com.pem
farkas@COIN-COIN:~/git/docker/tp2/cert$ ls |grep pem
CA.pem
pma.supersite.com.pem
www.supersite.com.pem
```

https://support.globalsign.com/digital-certificates/digital-certificate-installation/install-client-digital-certificate-firefox-windows

j'ai suivi ce mini tuto pour ajouter le CA.pem dans les certificats