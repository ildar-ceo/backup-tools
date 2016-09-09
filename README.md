# Утилиты для создания бэкапов


## Установка

```bash
cd /root
git clone https://github.com/vistoyn/backup_tools
cp /root/backup_tools/config.example /root/backup_tools/config
```

Измените настройки файла `/root/backup_tools/config`


## Бэкап папки в Amazon S3

Создайте простой скрипт `/root/backup.sh`
```bash
. /root/backup_tools/config

sync_sheme_set "amazon_s3"

sync_folder /root /root
sync_folder_start

sync_folder /etc /etc
sync_folder_start
```

Запустите его. Папки `/root` и `/etc` должны быть загружены в Amazon S3.


## Бэкап mysql

```bash

sync_sheme_set "amazon_s3"

dump_mysql "db1"
dump_mysql "db2"
dump_mysql "db3"

sync_folder /backup/mysql /mysql
push_folder_start
```


# Описание функций

* sync_sheme_set <type> - устанавливает схему синхронизации папки. Доступны варианты: amazon_s3, rsync
* sync_folder <src> <dest> - инициализирует синхронизацию
* sync_folder_start - запускает сихронизацию
* push_folder_start - заливает в хранилище данные, без удаления удаленных файлов
* dump_mysql <database_name> - делает бэкап базы данных mysql 
* dump_mongo <database_name> - делает бэкап базы данных mongodb 

Если нужно удалять устаревшие файлы из бэкапов, то можно это сделать коммандой:
```bash
find /backup/mysql -type f -mtime +30 -exec rm -f {} \;
find /backup/mongo -type f -mtime +30 -exec rm -f {} \;
```
Данная комманда удаляет файлы, старше 30 дней.