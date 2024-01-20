sudo setenforce 0
echo "SELINUX=disabled
SELINUXTYPE=targeted" | sudo tee /etc/selinux/config > /dev/null

sudo dnf update -y
sudo dnf install keepalived -y

sudo dnf install nginx -y
sudo systemctl enable --now nginx

echo "10.5.1.11 web1.tp5.b2" | sudo tee -a /etc/hosts
echo "10.5.1.12 web2.tp5.b2" | sudo tee -a /etc/hosts
echo "10.5.1.13 web3.tp5.b2" | sudo tee -a /etc/hosts

echo "upstream app_nulle_servers {
    server web1.tp5.b2:80;
    server web2.tp5.b2:80;
    server web3.tp5.b2:80;
}

server {
    listen 80;
    server_name 10.5.1.110;

    location / {
        proxy_pass http://app_nulle_servers;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
" | sudo tee /etc/nginx/conf.d/app_nulle.tp5.conf > /dev/null


sudo nginx -t
sudo systemctl reload nginx

echo "vrrp_instance VI_1 {
    state MASTER
    interface eth1 
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass password123
    }
    virtual_ipaddress {
        10.5.1.110/24
    }
}" |sudo tee /etc/keepalived/keepalived.conf
sudo systemctl restart keepalived
sudo systemctl enable keepalived

sudo reboot