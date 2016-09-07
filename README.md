# Утилиты для создания бэкапов


Установка:
```bash
cd /root
git clone https://github.com/vistoyn/backup_tools
cp /root/backup_tools/config.example /root/backup_tools/config
```

Измените настройки файла `/root/backup_tools/config`

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
