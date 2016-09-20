# Tools for create backups on Centos/Debian/Ubuntu

Support MySQL, MongoDB, LXD, Rsync, Amazon S3

**Warning!**
LXD works correctly only on Ubuntu 16.04 LTS


## Downloads

[download rpm](https://github.com/vistoyn/backup-tools/releases/download/1.1/backup-tools-1.1.0-9.noarch.rpm)
[download deb](https://github.com/vistoyn/backup-tools/releases/download/1.1/backup-tools_1.1.0-8_all.deb)


## Create backup user

**Important!**
Create user and group for backup and runs the script under them!
If you want to run backups as root then you do so at your own risk!

for Ubuntu
```
usermod -d /home/backup -s /bin/bash backup
mkdir -p /home/backup
chown backup:backup /home/backup
chmod 700 /home/backup
```

for Centos
```
groupadd -g 410 -r backup
useradd -g 410 -u 410 -r -m -s /bin/bash backup
touch /var/log/backup.log
chown backup:backup /var/log/backup.log
```

And allow backup user to backup folder:
```
mkdir -p /backup
chown backup:backup /backup
```


## Install on Centos 7


```bash
cd /src
wget https://github.com/vistoyn/backup-tools/releases/download/1.1/backup-tools-1.1.0-9.noarch.rpm
yum install s3cmd zip unzip tar gzip
rpm -Uvh backup-tools-1.1.0-9.noarch.rpm
```

**For MySQL backups**
```
yum install mysql
```

**For MongoDB backups**
```
yum install mongodb
```


## Install on Debian or Ubuntu

```bash
cd /src
wget https://github.com/vistoyn/backup-tools/releases/download/1.1/backup-tools_1.1.0-8_all.deb
apt-get install s3cmd zip unzip tar gzip
dpkg -i backup-tools_1.1.0-8_all.deb
```

**For MySQL backups**
```
apt-get install mysql-client
```

**For MongoDB backups**
```
apt-get install mongodb-clients
```


## Settings

Config file is save in folder `/etc/backup-tools`
```
cp /etc/backup-tools/config.example /etc/backup-tools/config
```

Example `/etc/backup-tools/config`:
```
BACKUP_DIR="/backup"  # whereis backup
LXD_STORAGE_BACKEND="dir"  # or zfs

MYSQL_HOST=""
MYSQL_USER=""
MYSQL_PASSWORD=""

MONGO_HOST=""
MONGO_USER=""
MONGO_PASSWORD=""

AMAZON_S3_BUCKET_NAME=""
AMAZON_S3_ACCESS_KEY_ID=""
AMAZON_S3_SECRET_ACCESS_KEY=""

. /usr/lib/backup-tools/config
```



## Backup MySQL and upload to Amazon S3

Make script:
```bash
nano /home/backup/backup.daily.sh
```
 

```bash
#!/bin/bash
#######################################################################
# **Important!**                                                      #
# Create user and group for backup and runs the script under them!    #
# If you want to run backups as root then you do so at your own risk! #
#######################################################################

. /etc/backup-tools/config

sync_sheme_set "amazon_s3"

dump_mysql "db1"
dump_mysql "db2"

echo "Upload MySQL Backups to Amazon S3"
sync_folder /backup/mysql /mysql
sync_folder_start
```


Set script as executable:
```bash
chmod +x /home/backup/backup.daily.sh
chown backup:backup /home/backup/backup.daily.sh
```


If you want restore MySQL backups, you should use MySQL client with next options:
```
SET NAMES utf8;
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';
source path-to-dump.sql
```


## Backup LXC in tar.gz and upload to Amazon S3

**Important!**
Unfortunately backup LXC doesn't make as "backup" user, you need root access.

```bash
#!/bin/bash

. /etc/backup-tools/config

sync_sheme_set "amazon_s3"

dump_lxc mycontainer

echo "Upload LXC to Amazon S3"
sync_folder /backup/lxc /lxc
push_folder_start
```

or from bash command:
```
sudo backup-lxc mycontainer
```

When container is backuping, automatically generated config in the container folder.

lxc backup may use exclude.list for tar backup. The exclude.list should be located in the folder `/var/lib/lxd/containers/mycontainer/exclude.list`

Example `exclude.list`:
```
rootfs/backup/*
rootfs/var/run/screen/*
rootfs/var/run/dbus/*
rootfs/var/lib/mysql/*
```


## Restore LXC from tar.gz backup


```bash
lxc image import ./path-to-backup.tar.gz --alias=mybackup
lxc stop mycontainer
lxc delete mycontainer
lxc init mybackup mycontainer
lxc config edit mycontainer < /var/lib/lxd/containers/mycontainer/config
lxc start mycontainer
```



## Add Script to Cron

Make `su backup -c "crontab -e"` and add next text:
```
# /etc/crontab: system-wide crontab
#
#* * * * * command
#- - - - -
#| | | | |
#| | | | ----- day of week (0 - 7) (Sunday =0 or =7)
#| | | ------- month (1 - 12)
#| | --------- day (1 - 31)
#| ----------- hour (0 - 23)
#------------- minute (0 - 59)

SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#m            h           dom     mon     dow     command
{minute}      {hour}      *       *       *       /home/backup/backup.daily.sh
```
Instead {minute} and {hour} type real values.


## Bash functions


* sync_sheme_set {type} - set sync sheme. Allow options: amazon_s3, rsync
* sync_folder {src} {dest} - initialize synchronization
* sync_folder_start - start synchronization of the folder
* push_folder_start - upload the folder, without deleting files in the recipient
* dump_mysql {database_name} - dump MySQL database
* dump_mongo {database_name} - dump MongoDB database
* dump_lxc {container_name} - dump LXC container



## Shell functions

* $ backup-lxc {container_name} - Backup LXC container to backup folder
* $ backup-mysql {database_name} - Backup MySQL database to backup folder
* $ backup-mongo {database_name} - Backup MongoDB database to backup folder



