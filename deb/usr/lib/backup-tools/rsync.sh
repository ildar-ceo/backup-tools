###############################################################################
#                               Backup Tools                                  #
#                                                                             #
# https://github.com/vistoyn/backup-tools                                     #
# Copyright (c) 2016 Ildar Bikmamatov <vistoyn@gmail.com>                     #
# Licensed under the MIT License                                              #
# (https://github.com/vistoyn/backup-tools/blob/master/LICENSE)               #
#                                                                             #
###############################################################################


sync_folder_exclude_rsync () {
	get_backup_log_var
	echo "$1/*" >> ${EXCLUDE_LIST}
	echo "exclude: $1 ">>${BACKUP_LOG}
	return 1
}

sync_folder_start_rsync () {
	params=""
	
	if [ -z "$CURRENT_SRC_FOLDER" ]; then
		return 0
	fi

	if [ -z "$CURRENT_DEST_FOLDER" ]; then
		return 0
	fi
	
	if [ "$VERBOSE" == "1" ]; then
		params="${params} --progress"
	fi
	
	get_backup_log_var
	
	echo "Start rsync folder $CURRENT_SRC_FOLDER/ to $CURRENT_DEST_FOLDER"
	echo "[`date -R`] Start rsync folder $CURRENT_SRC_FOLDER/ to $CURRENT_DEST_FOLDER ">>${BACKUP_LOG}
	
	CMD="rsync -azh ${params} --delete-after --force --exclude-from='${EXCLUDE_LIST}' $CURRENT_SRC_FOLDER/  $CURRENT_DEST_FOLDER"
	echo $CMD >> ${BACKUP_LOG}
	
	if [ "$VERBOSE" == "1" ]; then
		echo $CMD
	fi
	
	eval $CMD >> ${BACKUP_LOG} 2>&1
	
	echo "[`date -R`] End   rsync folder $CURRENT_SRC_FOLDER/ to $CURRENT_DEST_FOLDER ">>${BACKUP_LOG}
	return 1
}

push_folder_start_rsync () {
	params=""
	
	if [ -z "$CURRENT_SRC_FOLDER" ]; then
		return 0
	fi

	if [ -z "$CURRENT_DEST_FOLDER" ]; then
		return 0
	fi
	
	if [ "$VERBOSE" == "1" ]; then
		params="${params} --progress"
	fi
	
	get_backup_log_var
	
	echo "Start rsync push folder $CURRENT_SRC_FOLDER/ to $CURRENT_DEST_FOLDER"
	echo "[`date -R`] Start rsync push folder $CURRENT_SRC_FOLDER/ to $CURRENT_DEST_FOLDER ">>${BACKUP_LOG}
	
	CMD="rsync -azh ${params} --force --exclude-from='${EXCLUDE_LIST}' $CURRENT_SRC_FOLDER/  $CURRENT_DEST_FOLDER"
	echo $CMD >> ${BACKUP_LOG}
	
	if [ "$VERBOSE" == "1" ]; then
		echo $CMD
	fi
	
	eval $CMD >> ${BACKUP_LOG} 2>&1
	
	echo "[`date -R`] End   rsync folder $CURRENT_SRC_FOLDER/ to $CURRENT_DEST_FOLDER ">>${BACKUP_LOG}
	return 1
}

