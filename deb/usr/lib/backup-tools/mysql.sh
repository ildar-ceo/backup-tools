###############################################################################
#                               Backup Tools                                  #
#                                                                             #
# https://github.com/vistoyn/backup_tools                                     #
# Copyright (c) 2016 Ildar Bikmamatov <vistoyn@gmail.com>                     #
# Licensed under the MIT License                                              #
# (https://github.com/vistoyn/backup_tools/blob/master/LICENSE)               #
#                                                                             #
###############################################################################


dump_mysql_enable_keys () {
	if [ -z "$1" ]; then
		return 0
	else
		echo "enable keys $1"
		FILE="$1"
		cat $FILE | sed -e 's/\/\*!40000 ALTER TABLE `.*` DISABLE KEYS \*\/;//g' | sed -e 's/\/\*!40000 ALTER TABLE `.*` ENABLE KEYS \*\/;//g' > ${FILE}.new
		rm $FILE
		mv ${FILE}.new ${FILE}
	fi
	return 0
}

dump_mysql_what () {
	if [ -z "$1" ]; then
		return 0
	fi
	if [ -z "$2" ]; then
		return 0
	fi
	
	DATE=`date -I`
	DATE2=`date "+%Y-%m"`
	DATE3=`date "+%d"`
	DATABASE=$1
	WHAT=$2
	DIR="$BACKUP_DIR_MYSQL/$DATE2/$DATE3"
	name="${DATABASE}.${DATE}"
	
	mkdir -p $DIR
	pushd $DIR > /dev/null
	
	echo "[`date -R`] Start make MYSQL backup: ${DATABASE} ${WHAT}" >> $BACKUP_LOG

	if [ $WHAT == "table" ]; then
		name="${name}.tables.sql"
		mysqldump --quote-names --quick --add-drop-table --compact --create-options --no-data --routines --host=$MYSQL_HOST --user=$MYSQL_USER --password=$MYSQL_PASSWORD $DATABASE > ./$name 2>>$BACKUP_LOG
	elif [ $WHAT == "data" ]; then
		name="${name}.data.sql"
		mysqldump --quote-names --quick --no-create-info --insert-ignore -c --host=$MYSQL_HOST --user=$MYSQL_USER --password=$MYSQL_PASSWORD $DATABASE > ./$name 2>>$BACKUP_LOG
	else
		name="${name}.sql"
		mysqldump --quote-names --quick --add-drop-table --create-options --insert-ignore --routines -c --host=$MYSQL_HOST --user=$MYSQL_USER --password=$MYSQL_PASSWORD $DATABASE > ./$name 2>>$BACKUP_LOG
	fi

	dump_mysql_enable_keys ./$name > /dev/null
	zip -9 ./$name.zip ./$name > /dev/null
	rm -f ./$name 
	
	
	echo "[`date -R`] End   make MYSQL backup: ${DATABASE} ${WHAT}" >> $BACKUP_LOG

	popd > /dev/null
	return 1
}


# Функция создания дампа БД (полностью, только данные, только структура)
dump_mysql () {
	if [ -z "$1" ]; then
		return 0
	fi

	echo "Dump mysql $1"
	dump_mysql_what $1 full
	dump_mysql_what $1 table
	dump_mysql_what $1 data

	return 1
}


