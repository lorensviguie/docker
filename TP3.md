# TP3 Admin : Vagrant

## 0. Intro blabla

## 1. Une première VM

🌞 Générer un Vagrantfile 

```bash
farkas@COIN-COIN:~/git/docker/work/vagrant/test$ ls
Vagrantfile
farkas@COIN-COIN:~/git/docker/work/vagrant/test$ cat Vagrantfile |head -n 5
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
```

🌞 Modifier le Vagrantfile 

```bash
farkas@COIN-COIN:~/git/docker/work/vagrant/test$ cat Vagrantfile |grep config.vm
  config.vm.box = "generic_ubunutu"
  config.vm.box_check_update = false
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  # config.vm.provider "virtualbox" do |vb|
  # config.vm.provision "shell", inline: <<-SHELL
```

🌞 Faire joujou avec une VM

```bash
farkas@COIN-COIN:~/git/docker/work/vagrant/test$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Box 'generic/ubuntu2204' could not be found. Attempting to find and install...
    default: Box Provider: virtualbox
[...]
    default: VirtualBox Version: 7.0
farkas@COIN-COIN:~/git/docker/work/vagrant/test$ vagrant status
Current machine states:

default                   running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.

farkas@COIN-COIN:~/git/docker/work/vagrant/test$ vagrant ssh
vagrant@ubuntu2204:~$ ls
vagrant@ubuntu2204:~$ ls -al
total 32
drwxr-x--- 4 vagrant vagrant 4096 Dec 25 21:33 .
drwxr-xr-x 3 root    root    4096 Dec 25 21:26 ..
-rw-r--r-- 1 vagrant vagrant  220 Jan  6  2022 .bash_logout
-rw-r--r-- 1 vagrant vagrant 3775 Dec 25 21:33 .bashrc
drwxr-xr-x 2 vagrant vagrant 4096 Dec 25 21:33 .cache
-rw-r--r-- 1 vagrant vagrant  807 Jan  6  2022 .profile
drwx------ 2 vagrant vagrant 4096 Jan 11 15:09 .ssh
-rw-r--r-- 1 vagrant vagrant   13 Dec 25 21:33 .vimrc

farkas@COIN-COIN:~/git/docker/work/vagrant/test$ vagrant halt
==> default: Attempting graceful shutdown of VM...
farkas@COIN-COIN:~/git/docker/work/vagrant/test$ vagrant status
Current machine states:

default                   poweroff (virtualbox)

The VM is powered off. To restart the VM, simply run `vagrant up`

farkas@COIN-COIN:~/git/docker/work/vagrant/test$ vagrant destroy -f
==> default: Destroying VM and associated drives...
```

## 2. Repackaging

🌞 Repackager la box que vous avez choisie

```bash
farkas@COIN-COIN:~/git/docker/work/vagrant/test$ vagrant package --output super_box.box
==> default: Exporting VM...
==> default: Compressing package to: /home/farkas/git/docker/work/vagrant/test/super_box.box
farkas@COIN-COIN:~/git/docker/work/vagrant/test$ ls
super_box.box  Vagrantfile
farkas@COIN-COIN:~/git/docker/work/vagrant/test$ vagrant box add super_box super_box.box
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'super_box' (v0) for provider: 
    box: Unpacking necessary files from: file:///home/farkas/git/docker/work/vagrant/test/super_box.box
==> box: Successfully added box 'super_box' (v0) for ''!
farkas@COIN-COIN:~/git/docker/work/vagrant/test$ vagrant box list
generic/ubuntu2204 (virtualbox, 4.3.10, (amd64))
super_box          (virtualbox, 0)
```

🌞 Repackager la box que vous avez choisie

```bash
Vagrant.configure("2") do |config|
  config.vm.box = "super_box"
  config.vm.box_check_update = false
```

## 3. Moult VMs

🌞 Adaptez votre Vagrantfile  

[le vagrant file](./partie1/Vagrantfile-3A)  

🌞 Adaptez votre Vagrantfile  

[l'autre vagrant file](./partie1/Vagrantfile-3B)