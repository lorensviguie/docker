

# I. Init

## 3. sudo c pa bo

🌞 Ajouter votre utilisateur au groupe docker
```powershell
farkas@COIN-COIN:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

## 4. Un premier conteneur en vif

🌞 Lancer un conteneur NGINX
```powershell
farkas@COIN-COIN:~$ docker run -d -p 9999:80 nginx
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
af107e978371: Pull complete 
336ba1f05c3e: Pull complete 
8c37d2ff6efa: Pull complete 
51d6357098de: Pull complete 
782f1ecce57d: Pull complete 
5e99d351b073: Pull complete 
7b73345df136: Pull complete 
Digest: sha256:bd30b8d47b230de52431cc71c5cce149b8d5d4c87c204902acf2504435d4b4c9
Status: Downloaded newer image for nginx:latest
2632d15c98fa0d140074e2a65b7d7d17bdf7a939d5b82f40e8ad6253fe8bc63f
farkas@COIN-COIN:~$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                                   NAMES
2632d15c98fa   nginx     "/docker-entrypoint.…"   9 seconds ago   Up 8 seconds   0.0.0.0:9999->80/tcp, :::9999->80/tcp   brave_antonelli
```

🌞 Visitons

```powershell
farkas@COIN-COIN:~$ docker logs 26
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
[...]
2023/12/21 14:49:29 [notice] 1#1: start worker process 33

farkas@COIN-COIN:~$ ss -lptn | grep 99
LISTEN 0      4096         0.0.0.0:9999      0.0.0.0:*                                          
LISTEN 0      4096            [::]:9999         [::]:*   

farkas@COIN-COIN:~$ curl localhost:9999
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

🌞 On va ajouter un site Web au conteneur NGINX
```powershell
farkas@COIN-COIN:~/nginx$ ls
index.html  site_nul.conf
```


🌞 Visitons

```powershell
farkas@COIN-COIN:~/nginx$ docker run -d -p 9999:8080 -v /home/farkas/nginx/index.html:/var/www/html/index.html -v /home/farkas/nginx/site_nul.conf:/etc/nginx/conf.d/site_nul.conf nginx
aec027d45154e72181c521c51e2a8a61493b6108b9c68ead5fa03ed6d23546cc
farkas@COIN-COIN:~/nginx$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                               NAMES
aec027d45154   nginx     "/docker-entrypoint.…"   23 seconds ago   Up 22 seconds   80/tcp, 0.0.0.0:9999->8080/tcp, :::9999->8080/tcp   zealous_elgamal
```


## 5. Un deuxième conteneur en vif

🌞 Lance un conteneur Python, avec un shell

```powershell
farkas@COIN-COIN:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED          STATUS          PORTS     NAMES
ed1703d504a0   python    "bash"    28 minutes ago   Up 28 minutes             festive_sammet
```

🌞 Installe des libs Pythonrt

```powershell
root@ed1703d504a0:/# pip install aiohttp
Collecting aiohttp
[...]
Installing collected packages: multidict, idna, frozenlist, attrs, yarl, aiosignal, aiohttp
Successfully installed aiohttp-3.9.1 aiosignal-1.3.1 attrs-23.1.0 frozenlist-1.4.1 idna-3.6 multidict-6.0.4 yarl-1.9.4
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv

root@ed1703d504a0:/# pip install aioconsole
Collecting aioconsole
[...]
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
```

# II. Images

## 1. Images publiques

🌞 Récupérez des images

```powershell
farkas@COIN-COIN:~/nginx$ docker images
REPOSITORY           TAG       IMAGE ID       CREATED       SIZE
linuxserver/wikijs   latest    869729f6d3c5   6 days ago    441MB
mysql                5.7       5107333e08a8   9 days ago    501MB
python               latest    fc7a60e86bae   13 days ago   1.02GB
wordpress            latest    fd2f5a0c6fba   2 weeks ago   739MB
python               3.11      22140cbb3b0c   2 weeks ago   1.01GB
nginx                latest    d453dd892d93   8 weeks ago   187MB
```

🌞 Lancez un conteneur à partir de l'image Python

```powershell
farkas@COIN-COIN:~/nginx$ docker exec -it friendly_darwin bash
root@a6898f633cca:/# python --version
Python 3.11.7
```

## 2. Construire une image

🌞 Ecrire un Dockerfile pour une image qui héberge une application Python

[le docker file](./docker_file_TP1/dockerfile)

```powershell
farkas@COIN-COIN:~/python_app_build$ docker build . -t python_app:version_de_ouf
[+] Building 11.4s (10/10) 
[...]
 => => naming to docker.io/library/python_app:version_de_ouf    
```

# III. Docker compose

🌞 Créez un fichier docker-compose.yml

```bash
farkas@COIN-COIN:~/compose_test$ cat docker-compose.yml 
version: "3"
[...]
    entrypoint: sleep 9999
```

🌞 Lancez les deux conteneurs avec docker compose

```powershell
farkas@COIN-COIN:~/compose_test$ docker compose up -d
[+] Running 3/3
 ✔ Network compose_test_default                  Created                                                                                                                                                                               0.1s 
 ✔ Container compose_test-conteneur_flopesque-1  Started                                                                                                                                                                               0.1s 
 ✔ Container compose_test-conteneur_nul-1        Started    
```

🌞 Vérifier que les deux conteneurs tournent

```bash
farkas@COIN-COIN:~/compose_test$ docker ps
CONTAINER ID   IMAGE     COMMAND        CREATED         STATUS         PORTS     NAMES
3ba65633cd54   debian    "sleep 9999"   5 seconds ago   Up 4 seconds             compose_test-conteneur_nul-1
f4d4ab4a5e3f   debian    "sleep 9999"   5 seconds ago   Up 4 seconds             compose_test-conteneur_flopesque-1
```

🌞 Pop un shell dans le conteneur conteneur_nul

```bash
 docker exec -it 3ba bash
root@3ba65633cd54:/# apt update -y
[...]
root@3ba65633cd54:/# apt install iputils-ping -y
[...]
root@3ba65633cd54:/# ping conteneur_flopesque
PING conteneur_flopesque (172.18.0.2) 56(84) bytes of data.
64 bytes from compose_test-conteneur_flopesque-1.compose_test_default (172.18.0.2): icmp_seq=1 ttl=64 time=0.191 ms
64 bytes from compose_test-conteneur_flopesque-1.compose_test_default (172.18.0.2): icmp_seq=2 ttl=64 time=0.092 ms
```

