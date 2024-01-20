sudo setenforce 0
echo "SELINUX=disabled
SELINUXTYPE=targeted" | sudo tee /etc/selinux/config > /dev/null

sudo dnf check-update -y
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo -y
sudo dnf install docker-ce docker-ce-cli containerd.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo dnf install git -y
git clone https://gitlab.com/it4lik/b2-linux-2023.git
mv b2-linux-2023/tp/admin/5/php /var/
cd /var/php/
sudo useradd --no-create-home --shell /usr/sbin/nologin php
sudo usermod -aG docker php
sudo rm -rf /var/php/src/submit.php
sudo rm -rf /var/php/src/get.php

echo "<?php
\$host = '10.5.1.211';
\$user = 'meo';
\$password = 'meo';
\$db = 'meo';
\$conn = new mysqli(\$host, \$user, \$password, \$db);
if (! \$conn) {
    echo \"Erreur de connexion à MariaDB<br />\";
}
\$sql = 'INSERT INTO meo (name, email) VALUES (?, ?)';
\$stmt = \$conn->prepare(\$sql);
if (\$stmt) {
    \$stmt->bind_param('ss', \$_POST[\"name\"], \$_POST[\"email\"]);
    \$stmt->execute();
    \$stmt->close();
}
\$conn->close();
?>
<html>
<body>
Hellooooooooooooo <?php echo \$_POST[\"name\"]; ?> 🐈
<br>
Your email address is: <?php echo \$_POST[\"email\"]; ?>
<br>
Everything has been sent to the database! (maybe it will work, or maybe it will explode because you didn't configure the database :( )
<br><br>
<input type=\"button\" value=\"Home\" onClick=\"document.location.href='/';\" />
</body>
</html>
" | sudo tee /var/php/src/submit.php > /dev/null

echo "<?php
\$host = '10.5.1.211';
\$user = 'meo';
\$password = 'meo';
\$db = 'meo';
\$conn = new mysqli(\$host, \$user, \$password, \$db);
if (! \$conn) {
    echo \"Erreur de connexion à MariaDB<br />\";
}

\$sql = 'select * from meo where name = ?';
\$stmt = \$conn->prepare(\$sql);
if (\$stmt) {
    \$stmt->bind_param('s', \$_POST[\"name\"]);
    \$stmt->execute();
    \$result = \$stmt->get_result();
    \$stmt->close();
}

mysqli_close(\$conn);

if (\$result->num_rows === 0) {
    printf(\"No results for user %s\", \$_POST[\"name\"]);
} else {
    foreach (\$result as \$row) {
        printf(\"User %s found! E-mail address: %s\n\", \$row[\"name\"], \$row[\"email\"]);
    }
}
?>

<html>
<body>
<br><br>
<input type=\"button\" value=\"Home\" onClick=\"document.location.href='/';\" />
</body>
</html>
" | sudo tee /var/php/src/get.php > /dev/null


echo "version: \"3\"

services:
  php:
    build:
      context: php/
    volumes:
      - ./src:/var/www/html
    restart: always
    ports:
      - \"80:80\"" | sudo tee /var/php/docker-compose.yml > /dev/null
    

sudo chown -R php /var/php

echo "[Unit]
Description=PHP Container Service
After=docker.service
Requires=docker.service

[Service]
User=php
WorkingDirectory=/var/php/
ExecStart=docker compose up -d
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/phpserv.service > /dev/null


sudo systemctl daemon-reload
sudo systemctl enable phpserv
sudo systemctl start phpserv
sudo reboot