# TP4 : Vers une maîtrise des OS Linux

## I. Partitionnement

### 1. LVM dès l'installation

🌞 Faites une install manuelle de Rocky Linux 

```bash
[it5@localhost ~]$ lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                       8:0    0   40G  0 disk 
├─sda1                    8:1    0  512M  0 part /boot
└─sda2                    8:2    0 25.3G  0 part 
  ├─rl00-root           253:0    0   10G  0 lvm  /
  ├─rl00-swap           253:1    0  956M  0 lvm  [SWAP]
  ├─rl00-pool00_tmeta   253:2    0    8M  0 lvm  
  │ └─rl00-pool00-tpool 253:4    0  4.6G  0 lvm  
  │   ├─rl00-pool00     253:5    0  4.6G  1 lvm  
  │   └─rl00-home       253:6    0  4.6G  0 lvm  /home
  ├─rl00-pool00_tdata   253:3    0  4.6G  0 lvm  
  │ └─rl00-pool00-tpool 253:4    0  4.6G  0 lvm  
  │   ├─rl00-pool00     253:5    0  4.6G  1 lvm  
  │   └─rl00-home       253:6    0  4.6G  0 lvm  /home
  └─rl00-var            253:7    0  4.7G  0 lvm  /var
[it5@localhost ~]$ df -h
Filesystem             Size  Used Avail Use% Mounted on
devtmpfs               4.0M     0  4.0M   0% /dev
tmpfs                  1.8G     0  1.8G   0% /dev/shm
tmpfs                  730M  8.6M  721M   2% /run
/dev/mapper/rl00-root  9.8G  959M  8.3G  11% /
/dev/sda1              488M  185M  267M  41% /boot
/dev/mapper/rl00-home  4.5G   40K  4.3G   1% /home
/dev/mapper/rl00-var   4.6G   83M  4.2G   2% /var
tmpfs                  365M     0  365M   0% /run/user/1000
[it5@localhost ~]$ sudo pvs
We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:
    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.
[sudo] password for it5: 
  PV         VG   Fmt  Attr PSize  PFree 
  /dev/sda2  rl00 lvm2 a--  25.32g <5.07g
[it5@localhost ~]$ sudo pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               rl00
  PV Size               <25.33 GiB / not usable 3.00 MiB
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              6483
  Free PE               1297
  Allocated PE          5186
  PV UUID               C02zzf-NbeP-JQEv-Iujm-M9RW-GFvd-p6oOga
[it5@localhost ~]$ sudo vgs
  VG   #PV #LV #SN Attr   VSize  VFree 
  rl00   1   5   0 wz--n- 25.32g <5.07g
[it5@localhost ~]$ sudo vgdisplay
  --- Volume group ---
  VG Name               rl00
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  9
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                5
  Open LV               4
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               25.32 GiB
  PE Size               4.00 MiB
  Total PE              6483
  Alloc PE / Size       5186 / <20.26 GiB
  Free  PE / Size       1297 / <5.07 GiB
  VG UUID               gObz1K-rCLp-d0Gu-uQFd-zVqF-3Bir-WCmClz
[it5@localhost ~]$ sudo lvs
  LV     VG   Attr       LSize   Pool   Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home   rl00 Vwi-aotz--  <4.65g pool00        2.98                                   
  pool00 rl00 twi-aotz--  <4.65g               2.98   11.18                           
  root   rl00 -wi-ao----  10.00g                                                      
  swap   rl00 -wi-ao---- 956.00m                                                      
  var    rl00 -wi-ao----   4.66g                                                      
```

### 2. Scénario remplissage de partition

🌞 Remplissez votre partition /home 

```bash
[it5@localhost ~]$ dd if=/dev/zero of=/home/it5/bigfile bs=4M count=10000
dd: error writing '/home/it5/bigfile': No space left on device
1088+0 records in
1087+0 records out
4559753216 bytes (4.6 GB, 4.2 GiB) copied, 10.6368 s, 429 MB/s
```

🌞 Constater que la partition est pleine

```bash
[it5@localhost ~]$ df -h |grep home
/dev/mapper/rl00-home  4.5G  4.3G     0 100% /home
```

🌞 Agrandir la partition

```bash
[it5@localhost ~]$ sudo pvs
  PV         VG   Fmt  Attr PSize  PFree 
  /dev/sda2  rl00 lvm2 a--  25.32g <5.07g      
[it5@localhost ~]$ sudo lvextend -l +100%FREE /dev/rl00/home
  Size of logical volume rl00/home changed from <4.65 GiB (1190 extents) to 9.71 GiB (2487 extents).
  WARNING: Sum of all thin volume sizes (9.71 GiB) exceeds the size of thin pool rl00/pool00 and the amount of free space in volume group (<5.07 GiB).
  WARNING: You have not turned on protection against thin pools running out of space.
  WARNING: Set activation/thin_pool_autoextend_threshold below 100 to trigger automatic extension of thin pools before they get full.
  Logical volume rl00/home successfully resized.
[it5@localhost ~]$ sudo resize2fs /dev/rl00/home
resize2fs 1.46.5 (30-Dec-2021)
Filesystem at /dev/rl00/home is mounted on /home; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
The filesystem on /dev/rl00/home is now 2546688 (4k) blocks long.

[it5@localhost ~]$ sudo lvs
  LV     VG   Attr       LSize   Pool   Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home   rl00 Vwi-aotz--   9.71g pool00        45.76                                  
  pool00 rl00 twi-aotz--  <4.65g               95.63  28.76                           
  root   rl00 -wi-ao----  10.00g                                                      
  swap   rl00 -wi-ao---- 956.00m                                                      
  var    rl00 -wi-ao----   4.66g
[it5@localhost ~]$ df -h | grep home
/dev/mapper/rl00-home  9.5G  4.3G  4.8G  48% /home      
```

🌞 Remplissez votre partition /home

```bash
[it5@localhost ~]$ dd if=/dev/zero of=/home/it5/bigfile bs=4M count=5000
dd: error writing '/home/it5/bigfile': No space left on device
2314+0 records in
2313+0 records out
9701515264 bytes (9.7 GB, 9.0 GiB) copied, 79.564 s, 122 MB/s
```

🌞 Utiliser ce nouveau disque pour étendre la partition /home de 40G

```bash
[it5@localhost ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
[it5@localhost ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
[it5@localhost ~]$ sudo vgextend rl00 /dev/sdb 
  Volume group "rl00" successfully extended
[it5@localhost ~]$ sudo vgs
  VG   #PV #LV #SN Attr   VSize  VFree 
  rl00   2   5   0 wz--n- 65.32g 45.06g
[it5@localhost ~]$ sudo lvextend -L +40G /dev/rl00/home 
  Size of logical volume rl00/home changed from 9.71 GiB (2487 extents) to 49.71 GiB (12727 extents).
  WARNING: Sum of all thin volume sizes (49.71 GiB) exceeds the size of thin pool rl00/pool00 and the amount of free space in volume group (<9.65 GiB).
  WARNING: You have not turned on protection against thin pools running out of space.
  WARNING: Set activation/thin_pool_autoextend_threshold below 100 to trigger automatic extension of thin pools before they get full.
  Logical volume rl00/home successfully resized.
[it5@localhost ~]$ sudo resize2fs /dev/rl00/home
resize2fs 1.46.5 (30-Dec-2021)
Filesystem at /dev/rl00/home is mounted on /home; on-line resizing required
old_desc_blocks = 2, new_desc_blocks = 7
The filesystem on /dev/rl00/home is now 13032448 (4k) blocks long.

[it5@localhost ~]$ df -h
Filesystem             Size  Used Avail Use% Mounted on
devtmpfs               4.0M     0  4.0M   0% /dev
tmpfs                  1.8G     0  1.8G   0% /dev/shm
tmpfs                  730M  8.6M  721M   2% /run
/dev/mapper/rl00-root  9.8G  959M  8.3G  11% /
/dev/sda1              488M  185M  267M  41% /boot
/dev/mapper/rl00-home   49G  9.1G   38G  20% /home
/dev/mapper/rl00-var   4.6G  105M  4.2G   3% /var
tmpfs                  365M     0  365M   0% /run/user/1000
```

## II. Gestion de users

🌞 Gestion basique de users

```bash
[it5@localhost var]$ sudo cat /etc/passwd |tail -n 6
it5:x:1000:1000:it5:/home/it5:/bin/bash
alice:x:1001:10::/home/alice:/bin/bash
bob:x:1002:10::/home/bob:/bin/bash
charlie:x:1003:10::/home/charlie:/bin/bash
eve:x:1004:1004::/home/eve:/bin/bash
backup:x:1005:1005::/var/backup:/bin/bash/nologin
```

🌞 La conf sudo doit être la suivante

```bash
[it5@localhost var]$ sudo cat /etc/sudoers |grep wheel
## Allows people in group wheel to run all commands
%wheel	ALL=(ALL)	NOPASSWD: ALL
# %wheel	ALL=(ALL)	NOPASSWD: ALL
[it5@localhost var]$ sudo cat /etc/sudoers |grep eve
eve ALL=(backup) /bin/ls
```

🌞 Le dossier /var/backup

```bash
[it5@localhost var]$ ls -al | grep backup
drwx------.  2 backup backup  4096 Jan 12 17:29 backup
[it5@localhost backup]$ ls -al
total 12
drwxr-xr-x.  2 backup backup 4096 Jan 12 17:29 .
drwxr-xr-x. 21 root   root   4096 Jan 12 17:28 ..
-rw-r-----.  1 backup backup   25 Jan 12 17:29 precious_backup
```

🌞 Mots de passe des users, prouvez que

```bash
[it5@localhost var]$ sudo cat /etc/shadow
it5:$6$4uV2G./IcPU4RGRE$nokfNPEzFZN6dNFxf6hLisv4t14y1krnTDBtr1WMCKyQ4kU/IC6DLT6JilGErhYC.VhWFPoicIYGlzSih5X8Q0::0:99999:7:::
alice:$6$0IVK2ByGx81ZhSjM$Kr5tgaiA3kIkHrhTkZNXsOMEMpHX2R7FC5rO3bn8yzOpAYMYMA1/rHgd1pPGHqTefrYzTvc1JiCWuTY3/Olss0:19734:0:99999:7:::
bob:$6$/blcHpXTWVY68o1D$/f/eTVMVc/cWzbsw1xedZYw6WZwU3lwxtbrlFEqMg/A.pwiHsTOxwphwI2x3Pi6dbYPX14sTvBjEQ3EJjoOc2.:19734:0:99999:7:::
charlie:$6$ACXgxEWSxxf23O1q$Cy94tbZleXadGbGS73ClkDxyT0ziZoZ3222lGAJtyWIQrm2IXXqdXC.xFcORNYBrWb0keYyFjGgfQdOYfevX61:19734:0:99999:7:::
eve:$6$9X5WQlPLTRPZeXU3$q.eGaP4.UQctUEK1ShqOzpb44Qi4ccHxDSsvz61ieh/92QAHO51uKkDd.qx0GHSNtTWADClcqHvfT6vXp26MZ1:19734:0:99999:7:::
```

🌞 User eve

```bash
[eve@localhost var]$ sudo -l
Matching Defaults entries for eve on localhost:
    !visiblepw, always_set_home, match_group_by_gid, always_query_group_plugin, env_reset, env_keep="COLORS DISPLAY HOSTNAME HISTSIZE KDEDIR LS_COLORS", env_keep+="MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS
    LC_CTYPE", env_keep+="LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES", env_keep+="LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE", env_keep+="LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET
    XAUTHORITY", secure_path=/sbin\:/bin\:/usr/sbin\:/usr/bin

User eve may run the following commands on localhost:
    (backup) /bin/ls
```

## III. Gestion du temps

🌞 Je vous laisse gérer le bail vous-mêmes

```bash
[it5@localhost var]$ systemctl list-units -t service -a | grep NTP
  chronyd.service                                                                           loaded    active   running NTP client/server
[it5@localhost var]$ timedatectl 
               Local time: Mon 2024-01-15 09:41:19 CET
           Universal time: Mon 2024-01-15 08:41:19 UTC
                 RTC time: Mon 2024-01-15 08:41:18
                Time zone: Europe/Paris (CET, +0100)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
[it5@localhost var]$ sudo cat /etc/chrony.conf |grep fr.pool
	   server 0.fr.pool.ntp.org
	   server 1.fr.pool.ntp.org
	   server 2.fr.pool.ntp.org
	   server 3.fr.pool.ntp.org
```