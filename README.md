# Tools for create backups on Centos/Debian/Ubuntu

Support Mysql, MongoDB, LXD, Rsync, Amazon S3


## Install on Centos 7


```bash
cd /src
wget https://github.com/vistoyn/backup-tools/backup-tools-1.1.0-6.noarch.rpm
yum install s3cmd zip unzip tar gzip
rpm -Uvh backup-tools-1.1.0-6.noarch.rpm
```

**For mysql backups**
```
yum install mysql
```

**For mongo backups**
```
yum install mongodb
```


## Install on Debian or Ubuntu

```bash
cd /src
wget https://github.com/vistoyn/backup-tools/backup-tools_1.1.0-5_all.deb
apt-get install s3cmd zip unzip tar gzip
dpkg -i backup-tools_1.1.0-5_all.deb
```

**For mysql backups**
```
apt-get install mysql-client
```

**For mongo backups**
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
BACKUP_DIR="/backup"
LXD_STORAGE_BACKEND="dir"

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


## Backup mysql and upload to Amazon S3

Make script:
```bash
nano /root/backup.daily.sh
```
 

```bash
#!/bin/bash
. /etc/backup-tools/config

sync_sheme_set "amazon_s3"

dump_mysql "db1"
dump_mysql "db2"

echo "Upload Mysql Backups to Amazon S3"
sync_folder /backup/mysql /mysql
sync_folder_start
```


Set script as executable:
```bash
chmod +x /root/backup.daily.sh
```


If you want restor mysql backup, you should use mysql client with next options:
```
SET NAMES utf8;
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';
source dump.sql
```


## Backup LXC and upload to Amazon S3

```bash
#!/bin/bash
. /etc/backup-tools/config

sync_sheme_set "amazon_s3"

dump_lxc test

echo "Upload LXC to Amazon S3"
sync_folder /backup/lxc /lxc
push_folder_start
```


## Add Script to Cron

Make `crontab -e` and add next text:
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

#m      h       dom     mon     dow     command
01      01      *       *       *       /root/backup.daily.sh
```


## Bash functions


* sync_sheme_set {type} - set sync sheme. Allow options: amazon_s3, rsync
* sync_folder {src} {dest} - initialize synchronization
* sync_folder_start - start synchronization of the folder
* push_folder_start - upload the folder, without deleting files in the recipient
* dump_mysql {database_name} - dump mysql database
* dump_mongo {database_name} - dump mongodb database
* dump_lxc {container_name} - dump LXC container



## Shell functions

* $ backup-lxc {container_name} - Make backup of the LXC Container


