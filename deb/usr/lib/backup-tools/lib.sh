###############################################################################
#                               Backup Tools                                  #
#                                                                             #
# https://github.com/vistoyn/backup-tools                                     #
# Copyright (c) 2016 Ildar Bikmamatov <vistoyn@gmail.com>                     #
# Licensed under the MIT License                                              #
# (https://github.com/vistoyn/backup-tools/blob/master/LICENSE)               #
#                                                                             #
###############################################################################


c_Green='\e[1;32m'        # Green
c_Yellow='\e[1;33m'       # Yellow
c_NC='\e[0m'              # No Color (нет цвета)


ask_yn() {
	if [ -z "$1" ]; then
		return 0
	fi
	
	echo -e -n "$@ [y/N]?"
	read -p " " yn

	if [ -z $yn ]; then
		return 0
	fi

	if [ $yn != "y" ] && [ $yn != "Y" ]; then
		return 0
	fi

	return 1
}


ask_yn_exit() {
	ask_yn $@
	
	if [ $? != 1 ]; then
		exit
	fi
}

get_backup_log_var(){
	BACKUP_LOG=""
	
	if [ $BACKUP_LOG_TYPE == "FILE" ]; then
		BACKUP_LOG=$BACKUP_LOG_FILE
	fi
	
	if [ $BACKUP_LOG_TYPE == "DIR" ]; then
		BACKUP_LOG="${BACKUP_LOG_DIR}/${BACKUP_LOG_NAME}-`date -I`.log"
	fi
}