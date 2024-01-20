# TP5 Admin : Haute-Dispo

[le vagrant file](./TP5/Vagrantfile)

🌞 Visitez l'app web depuis votre navigateur

```bash
farkas@COIN-COIN:~/git/docker/TP5$ curl http://app_null.tp5.b2
<html>
<body>

  <h2>Insert user</h2>
  <form action="submit.php" method="post">
    Name: <input type="text" name="name"><br>
    E-mail: <input type="text" name="email"><br>
    <input type="submit">
  </form>
  
  <h2>Get user</h2>
    <form action="get.php" method="post">
    Name: <input type="text" name="name"><br>
    <input type="submit">
  </form>

</body>
</html>

```

🌞 J'ai dit de tester que ça marchait

```bash
echo "vrrp_instance VI_1 {
    state BACKUP
    interface eth1  
    virtual_router_id 51
    priority 50
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass password123
    }
    virtual_ipaddress {
        10.5.1.110/24
    }
}" |sudo  tee /etc/keepalived/keepalived.conf
sudo systemctl restart keepalived
[vagrant@rp1 conf.d]$ sudo reboot
echo "vrrp_instance VI_1 {
    state BACKUP
    interface eth1  
    virtual_router_id 51
    priority 50
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass password123
    }
    virtual_ipaddress {
        10.5.1.110/24
    }
}" |sudo  tee /etc/keepalived/keepalived.conf
sudo systemctl restart keepalived
```