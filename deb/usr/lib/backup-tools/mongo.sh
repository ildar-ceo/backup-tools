###############################################################################
#                               Backup Tools                                  #
#                                                                             #
# https://github.com/vistoyn/backup-tools                                     #
# Copyright (c) 2016 Ildar Bikmamatov <vistoyn@gmail.com>                     #
# Licensed under the MIT License                                              #
# (https://github.com/vistoyn/backup-tools/blob/master/LICENSE)               #
#                                                                             #
###############################################################################


# Функция создания дампа БД 
dump_mongo () {
	if [ -z "$1" ]; then
		return 0
	fi
	
	get_backup_log_var
	
	DATE=`date -I`
	DATE2=`date "+%Y-%m"`
	DATE3=`date "+%d"`
	DATABASE=$1
	WHAT=$2
	DIR="$BACKUP_DIR_MONGO/$DATE2/$DATE3"
	name="${DATABASE}.${DATE}"
	
	mkdir -p $DIR
	pushd $DIR > /dev/null
	
	echo "[`date -R`] Start make Mongodb backup: ${DATABASE}" >> $BACKUP_LOG
	
	echo "Dump mongodb $1"
	
	if [ ! -z "$MONGO_USER" ] && [ ! -z "$MONGO_PASSWORD" ]; then
	
		mongodump -h $MONGO_HOST -u $MONGO_USER -p $MONGO_PASSWORD \
			--authenticationDatabase admin --db $1 --out ./ >> $BACKUP_LOG 2>&1
	
	else
		
		mongodump -h $MONGO_HOST  \
			--db $1 --out ./ >> $BACKUP_LOG 2>&1
		
	fi
	
	echo "Compress to zip"
	zip -r9 ./$name.zip ./$DATABASE > /dev/null
	rm -f ./$DATABASE/* > /dev/null
	rmdir ./$DATABASE > /dev/null
	
	echo "[`date -R`] End make   Mongodb backup: ${DATABASE}" >> $BACKUP_LOG
	
	popd > /dev/null
	return 1
}
