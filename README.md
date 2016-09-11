# Tools for create backups

Support Mysql, MongoDB, LXD, Rsync, Amazon S3


## Install on Centos 7


```bash
cd /src
wget https://github.com/vistoyn/backup-tools/backup-tools-1.1.0-2.noarch.rpm
yum install mysql s3cmd mongo
rpm -Uvh backup-tools-1.1.0-2.noarch.rpm
```


## Install on Debian

```bash
cd /src
wget https://github.com/vistoyn/backup-tools/backup-tools_1.1.0_all.deb
apt-get install mysql s3cmd mongo
dpkg -i backup-tools_1.1.0_all.deb
```


## Settings

Config file is save in folder /etc/backup-tools
```
cp /etc/backup-tools/config.example /etc/backup-tools/config
```

Example config:
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

Make script `nano ~/backup.daily.sh`:

```bash
#!/bin/bash
. /etc/backup-tools/config

sync_sheme_set "amazon_s3"

dump_mysql "db1"
dump_mysql "db2"

echo "Upload to Amazon S3 Mysql Backups"
sync_folder /backup/mysql /mysql
sync_folder_start
```



# Bash functions


* sync_sheme_set <type> - set sync sheme. Allow options: amazon_s3, rsync
* sync_folder <src> <dest> - initialize synchronization
* sync_folder_start - start synchronization of the folder
* push_folder_start - upload the folder, without deleting files in the recipient
* dump_mysql <database_name> - dump mysql database
* dump_mongo <database_name> - dump mongodb database



# Shell functions

* $ backup-lxc <container_name> - Make backup of the LXC Container


